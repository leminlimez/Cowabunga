#import <Foundation/Foundation.h>

#define log(fmt, ...) fputs([NSString stringWithFormat:fmt "\n", ## __VA_ARGS__].UTF8String, stderr)
#undef assert
#define assert(x) ({if (!(x)) {log(@"Assertion failed: '%s'. The font is either corrupt or unsupported in an unexpected way, please report this.", #x); abort();} })

static void repack_glyf(NSData *glyf, NSData *loca, NSData **out_glyf, NSData **out_loca, bool uses_16bit_loca)
{
    /* The glyf table contains glyph data, and the loca table contains the offsets of each glyph. Reconstruct the gylf
       table so nothing is ever using the last byte of a page, while reconstructing the loca table to reflect the new
       gylph offsets. */
    
    /* Todo: It's possible to save bytes by removing the hinting instructions from the glyphs. They're not used on
       by Apple's font renderer anyway. */
    *out_loca = [loca mutableCopy];
    uint16_t *offsets = [*(NSMutableData **)out_loca mutableBytes];
    uint32_t *offsets32 = (void *)offsets;
    unsigned count = uses_16bit_loca? (loca.length / 2) : (loca.length / 4);
    *out_glyf = [NSMutableData data];
    for (unsigned i = 0; i < count; i++) {
        size_t offset = uses_16bit_loca? (htons(offsets[i]) * 2) : htonl(offsets32[i]);
        /* Calculating the glyph size is actually tricky, let's assume glyphs go one after another and subtract the
           offset of the next glyph (or the table end) from the start. If we ever encounter a font that breaks this
           assumption, we'll assert about hopefully somebody will complain about it. */
        size_t size = glyf.length - offset;
        if (i != count - 1) {
            size = uses_16bit_loca? (htons(offsets[i + 1]) * 2 - offset) : ((htonl(offsets32[i + 1]) - offset));
        }
        assert(size < 0x1000); // Make sure the size is reasonable
        assert(size + offset <= glyf.length);
        if (([*out_glyf length] & 0x3FFF) + size >= 0x3FFF) {
            ((NSMutableData *)(*out_glyf)).length += 0x4000 - (([*out_glyf length] & 0x3FFF));
        }
        NSData *data = [glyf subdataWithRange:NSMakeRange(offset, size)];
        if (uses_16bit_loca) {
            offsets[i] = htons((*out_loca).length / 2);
        }
        else {
            offsets32[i] = htonl((*out_loca).length);
        }
        [((NSMutableData *)*out_glyf) appendData:data];
    }
}

NSData *repack_ttc(NSData *original, bool delete_noncritical, bool allow_corrupt_loca)
{
    if (original.length < 0x4000) {
        return original;
    }
    
    struct ttc_header_s {
        uint32_t magic;
        uint32_t version;
        uint32_t fonts;
        uint32_t offsets[];
    };
    const struct ttc_header_s *ttc_header = original.bytes;
    
    struct table_record_s {
        uint32_t tag;
        uint32_t checksum;
        uint32_t offset;
        uint32_t length;
    };
    
    struct header_s {
        uint32_t magic;
        uint16_t tables;
        uint16_t search_range;
        uint16_t entry_selector;
        uint16_t range_shift;
        struct table_record_s records[];
    };
    
    if (ttc_header->magic != htonl('ttcf')) {
        log(@"This doesn't seem to be a TrueType Collection file.");
        return nil;
    }
    
    uint32_t count = htonl(ttc_header->fonts);
    
    /* Step 0: Iterate every font, and save its header + table directory */

    NSMutableArray <NSMutableData *> *fonts = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        size_t offset = htonl(ttc_header->offsets[i]);
        const struct header_s *header = (const void *)((const uint8_t *)original.bytes + offset);
        assert(original.length - offset > sizeof(*header));
        size_t size = sizeof(*header) + sizeof(header->records[0]) * htons(header->tables);
        assert(original.length - offset > size);
        [fonts addObject:[NSMutableData dataWithBytes:header length:size]];
    }
    
    /* Step 1: for each font, go over the tables and:
       1. Delete non-critical ones if needed
       2. Recreate the glyf and loca tables if glyf is larger than a page
       3. Store every table data in the `global_tables` dict, so we can add them back when recreating the TTC file */
    NSMutableDictionary<NSNumber *, NSData *> *global_tables = [NSMutableDictionary dictionary];
    for (NSMutableData *font in fonts) {
        struct header_s *header = font.mutableBytes;
        NSMutableDictionary<NSNumber *, NSData *> *tables = [NSMutableDictionary dictionary];
        for (unsigned i = htons(header->tables); i--;) {
            // Filter unessential tables
            switch (htonl(header->records[i].tag)) {
                default:
                    if (delete_noncritical) {
                        char tag[5] = {0,};
                        *(uint32_t *)&tag[0] = header->records[i].tag;
                        log(@"Deleted unessential table '%s', saving %d bytes.", tag, htonl(header->records[i].length));
                        memmove(&header->records[i], &header->records[i + 1], sizeof(header->records[i]) * (htons(header->tables) - i - 1));
                        header->tables = htons(htons(header->tables) - 1);
                        font.length -= sizeof((header->records[i]));
                        header = font.mutableBytes;
                        break;
                    }
                case 'GDEF':
                case 'GPOS':
                case 'GSUB':
                case 'cmap':
                case 'glyf':
                case 'head':
                case 'hhea':
                case 'hmtx':
                case 'kern':
                case 'loca':
                case 'maxp':
                case 'name':
                case 'post': {
                    NSData *data = [original subdataWithRange:NSMakeRange(htonl(header->records[i].offset),
                                                                          htonl(header->records[i].length))];
                    assert(data.length == htonl(header->records[i].length));
                    tables[@(header->records[i].tag)] = data;
                    global_tables[@(header->records[i].offset)] = data;
                    break;
                }

            }
        }
        
        NSData *head = tables[@(htonl('head'))];
        NSData *loca = tables[@(htonl('loca'))];
        NSData *glyf = tables[@(htonl('glyf'))];
        
        assert(head.length >= 0x34);
        bool uses_16bit_loca = ((uint16_t *)head.bytes)[0x19] == 0;
        
        if (loca.length > 0x3fff) {
            if (allow_corrupt_loca) {
                log(@"One of the fonts contain %lu glyphs, while the currently supported maximum is %d. Some glyphs "
                    "will be corrupt and potentially cause stability issues.", loca.length / 2, uses_16bit_loca? 8191 : 4095);
            }
            else {
                log(@"One of the fonts contain %lu glyphs, while the currently supported maximum is %d. You can "
                    "force conversion to continue using the -f flag, at the cost of some corrupt glyphs and potential "
                    "stability issues.", loca.length / 2, uses_16bit_loca? 8191 : 4095);
                return nil;
            }
        }
        
        if (loca.length > 0x3fff || glyf.length > 0x3fff) {
            repack_glyf(glyf, loca, &glyf, &loca, uses_16bit_loca);
            tables[@(htonl('loca'))] = loca;
            tables[@(htonl('glyf'))] = glyf;
        }
    }
    
    /* Step 2: Assign every table to a page. Reserve space in the first page for the TTC header and TTF headers and
       table directories. Some items in the page array may actually be several pages large (if they start with a glyph
       or loca table), so also keep track of the starting address for each page. */
    
    NSMutableArray <NSMutableData *> *pages = [NSMutableArray array];
    NSMutableArray <NSNumber *> *page_starts = [NSMutableArray array];
    NSMutableDictionary <NSNumber *, NSNumber *> *new_offsets = [NSMutableDictionary dictionary];
    size_t first_page_size = sizeof(*ttc_header) + count * sizeof(ttc_header->offsets[0]);
    for (NSData *font in fonts) {
        first_page_size += font.length;
    }
    
    assert(first_page_size <= 0x3FFF);
    
    [pages addObject:[NSMutableData dataWithLength:first_page_size]];
    [page_starts addObject:@0];
    
    uint32_t next_page = 0x4000;
    
    // Native, but good enough. Might need a less silly algorithm if font size ever becomes an issue.
    for (NSNumber *original_offset in global_tables) {
        NSData *data = global_tables[original_offset];
        // Tables over 0x3FFF bytes long are already preprocessed and assume being page aligned
        if (data.length >= 0x3FFF) {
        no_space:
            new_offsets[original_offset] = @(next_page);
            [pages addObject:data.mutableCopy];
            [page_starts addObject:@(next_page)];
            next_page += 0x4000 + (data.length & ~0x3FFF);
            continue;
        }
        for (NSMutableData *page in pages) {
            if ((page.length & 0x3FFF) + data.length <= 0x3FFF) {
                unsigned index = [pages indexOfObject:page];
                new_offsets[original_offset] = @(page_starts[index].unsignedIntValue + page.length);
                [page appendData:data];
                goto cont;
            }
        }
        goto no_space;
    cont:;
    }
    
    /* Step 3: Update the table directories and fill the space we reserved in the first page. */
    struct ttc_header_s *new_ttc_header = pages[0].mutableBytes;
    new_ttc_header->magic = ttc_header->magic;
    new_ttc_header->version = ttc_header->version;
    new_ttc_header->fonts = ttc_header->fonts;
    uint32_t table_offset = sizeof(*new_ttc_header) + count * sizeof(new_ttc_header->offsets[0]);
    unsigned index = 0;
    for (NSData *font in fonts) {
        new_ttc_header->offsets[index] = htonl(table_offset);
        struct header_s *header = (void *)((uint8_t *)pages[0].mutableBytes + table_offset);
        memcpy(header, font.bytes, font.length);
        for (unsigned i = htons(header->tables); i--;) {
            header->records[i].length = htonl(global_tables[@(header->records[i].offset)].length);
            header->records[i].offset = htonl(new_offsets[@(header->records[i].offset)].unsignedIntValue);
            // Todo: Update checksum
        }
        table_offset += font.length;
        index++;
    }
    
    
    // Step 4: Join the pages together
    NSMutableData *output = [NSMutableData data];
    for (NSMutableData *page in pages) {
        if (page != pages.lastObject) {
            size_t length = page.length;
            length |= 0x3FFF;
            length++;
            page.length = length;
        }
        [output appendData:page];
    }
    
    return output;
}

#if 0
int main(int argc, const char * argv[])
{
    NSMutableArray<NSString *> *args = [[NSProcessInfo processInfo] arguments].mutableCopy;
    [args removeObjectAtIndex:0];
    
    bool delete_noncritical = false;
    if ([args containsObject:@"-d"]) {
        delete_noncritical = true;
        [args removeObject:@"-d"];
    }
    
    bool allow_corrupt_loca = false;
    if ([args containsObject:@"-f"]) {
        allow_corrupt_loca = true;
        [args removeObject:@"-f"];
    }
    
    if (args.count != 2) {
        log(@"Usage: %s [-f] [-d] input.ttc output.ttc", argv[0]);
        exit(1);
    }
    
    NSError *error = nil;
    NSData *source = [NSData dataWithContentsOfFile:args[0] options:0 error:&error];
    
    if (!source) {
        log(@"Could not read file %@: %@", args[0], error.localizedDescription);
        return 1;
    }
    
    NSData *dest = repack_ttc(source, delete_noncritical, allow_corrupt_loca);
    
    if (!dest) {
        log(@"Could not repack TTC file.");
        return 1;
    }
    
    if (![dest writeToFile:args[1] options:0 error:&error]) {
        log(@"Could not write file %@: %@", args[1], error.localizedDescription);
        return 1;
    }
    
    return 0;
}
#endif
