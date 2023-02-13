#pragma once
@class NSData;
NSData *repack_ttc(NSData *original, bool delete_noncritical, bool allow_corrupt_loca);
