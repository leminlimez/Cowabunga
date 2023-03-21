//
//  OverwriteFontImpl.swift
//  Cowabunga
//
//  Created by lemin on 2/22/23.
//
// Credit: FontOverwrite

import Foundation

class OverwriteFontImpl {
    static func dumpCurrentFont() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ].path
        let pathToTargetFont = documentDirectory + "/FontsDump/SFUI_dump.ttf"
        let pathToRealTargetFont = "/System/Library/Fonts/CoreUI/SFUI.ttf"
        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTargetFont))
        try! origData.write(to: URL(fileURLWithPath: pathToTargetFont))
    }
    
    static func overwriteWithFont(fontURL: URL, pathToTargetFont: String) throws {
        try overwriteWithFontImpl(fontURL: fontURL, pathToTargetFont: pathToTargetFont)
    }
    
    // Overwrite the system font with the given font using CVE-2022-46689.
    static func overwriteWithFontImpl(fontURL: URL, pathToTargetFont: String) throws {
        var fontData: Data = try! Data(contentsOf: fontURL)
    #if false
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].path
        
        let pathToTargetFont = documentDirectory + "/FontsDump/SFUI.ttf"
        let pathToRealTargetFont = "/System/Library/Fonts/CoreUI/SFUI.ttf"
        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTargetFont))
        try! origData.write(to: URL(fileURLWithPath: pathToTargetFont))
    #endif
        
        // open and map original font
        let fd = open(pathToTargetFont, O_RDONLY | O_CLOEXEC)
        if fd == -1 {
            throw "Unable to open font!"
        }
        defer { close(fd) }
        // check size of font
        let originalFontSize = lseek(fd, 0, SEEK_END)
        guard originalFontSize >= fontData.count else {
            throw "Font too big!"
        }
        lseek(fd, 0, SEEK_SET)
        
        if fontData[0..<4] == Data([0x77, 0x4f, 0x46, 0x32]) {
            // if this is a woff2 (and not a ttc)
            // patch our font with the padding
            // https://www.w3.org/TR/WOFF2/#woff20Header
            // length
            withUnsafeBytes(of: UInt32(originalFontSize).bigEndian) {
                fontData.replaceSubrange(0x8..<0x8 + 4, with: $0)
            }
            // privOffset
            withUnsafeBytes(of: UInt32(fontData.count).bigEndian) {
                fontData.replaceSubrange(0x28..<0x28 + 4, with: $0)
            }
            // privLength
            withUnsafeBytes(of: UInt32(Int(originalFontSize) - fontData.count).bigEndian) {
                fontData.replaceSubrange(0x2c..<0x2c + 4, with: $0)
            }
        }
        
        // Map the font we want to overwrite so we can mlock it
        let fontMap = mmap(nil, fontData.count, PROT_READ, MAP_SHARED, fd, 0)
        if fontMap == MAP_FAILED {
            throw "Font mapping failed!"
        }
        // mlock so the file gets cached in memory
        guard mlock(fontMap, fontData.count) == 0 else {
            throw "Failed to mlock font!"
        }
        
        // for every 16k chunk, rewrite
        for chunkOff in stride(from: 0, to: fontData.count, by: 0x4000) {
            print(String(format: "%lx", chunkOff))
            let dataChunk = fontData[chunkOff..<min(fontData.count, chunkOff + 0x4000)]
            var overwroteOne = false
            for _ in 0..<2 {
                let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                    return unaligned_copy_switch_race(
                        fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count, false)
                }
                if overwriteSucceeded {
                    overwroteOne = true
                    break
                }
                print("try again?!")
            }
            guard overwroteOne else {
                throw "Failed to overwrite font!"
            }
        }
    }
}
