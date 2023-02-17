//
//  OverwriteFontImpl.swift
//  WDBFontOverwrite
//
//  Created by Zhuowei Zhang on 2022-12-25.
//

import UIKit
import UniformTypeIdentifiers

//class OverwriteFontImpl {
//    func overwriteWithFont(name: String) async {
//        let fontURL = Bundle.main.url(
//            forResource: name,
//            withExtension: nil,
//            subdirectory: "RepackedFonts"
//        )!
//        
//        await overwriteWithFont(
//            fontURL: fontURL,
//            pathToTargetFont: "/System/Library/Fonts/CoreUI/SFUI.ttf"
//        )
//    }
//    
//    func overwriteWithFont(
//        fontURL: URL,
//        pathToTargetFont: String
//    ) async {
//        overwriteWithFontImpl(
//            fontURL: fontURL,
//            pathToTargetFont: pathToTargetFont
//        )
//    }
//    
//    /// Overwrite the system font with the given font using CVE-2022-46689.
//    /// The font must be specially prepared so that it skips past the last byte in every 16KB page.
//    /// See BrotliPadding.swift for an implementation that adds this padding to WOFF2 fonts.
//    func overwriteWithFontImpl(
//        fontURL: URL,
//        pathToTargetFont: String
//    ) {
//        var fontData: Data = try! Data(contentsOf: fontURL)
//#if false
//        let documentDirectory = FileManager.default.urls(
//            for: .documentDirectory,
//            in: .userDomainMask
//        )[0].path
//        
//        let pathToTargetFont = documentDirectory + "/SFUI.ttf"
//        let pathToRealTargetFont = "/System/Library/Fonts/CoreUI/SFUI.ttf"
//        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTargetFont))
//        try! origData.write(to: URL(fileURLWithPath: pathToTargetFont))
//#endif
//        
//        // open and map original font
//        let fd = open(pathToTargetFont, O_RDONLY | O_CLOEXEC)
//        if fd == -1 {
//            sendImportMessage(.failure("Unable to open font."))
//            return
//        }
//        defer { close(fd) }
//        // check size of font
//        let originalFontSize = lseek(fd, 0, SEEK_END)
//        guard originalFontSize >= fontData.count else {
//            sendImportMessage(.failure("Font too big."))
//            return
//        }
//        lseek(fd, 0, SEEK_SET)
//        
//        if fontData[0..<4] == Data([0x77, 0x4f, 0x46, 0x32]) {
//            // if this is a woff2 (and not a ttc)
//            // patch our font with the padding
//            // https://www.w3.org/TR/WOFF2/#woff20Header
//            // length
//            withUnsafeBytes(of: UInt32(originalFontSize).bigEndian) {
//                fontData.replaceSubrange(0x8..<0x8 + 4, with: $0)
//            }
//            // privOffset
//            withUnsafeBytes(of: UInt32(fontData.count).bigEndian) {
//                fontData.replaceSubrange(0x28..<0x28 + 4, with: $0)
//            }
//            // privLength
//            withUnsafeBytes(of: UInt32(Int(originalFontSize) - fontData.count).bigEndian) {
//                fontData.replaceSubrange(0x2c..<0x2c + 4, with: $0)
//            }
//        }
//        
//        // Map the font we want to overwrite so we can mlock it
//        let fontMap = mmap(nil, fontData.count, PROT_READ, MAP_SHARED, fd, 0)
//        if fontMap == MAP_FAILED {
//            sendImportMessage(.failure("Map failed"))
//            return
//        }
//        // mlock so the file gets cached in memory
//        guard mlock(fontMap, fontData.count) == 0 else {
//            sendImportMessage(.failure("Can't mlock"))
//            return
//        }
//        
//        updateProgress(total: true, progress: Double(fontData.count))
//        
//        // for every 16k chunk, rewrite
//        print(Date())
//        for chunkOff in stride(from: 0, to: fontData.count, by: 0x4000) {
//            print(String(format: "%lx", chunkOff))
//            if chunkOff % 0x40000 == 0 {
//                updateProgress(total: false, progress: Double(chunkOff))
//            }
//            let dataChunk = fontData[chunkOff..<min(fontData.count, chunkOff + 0x4000)]
//            var overwroteOne = false
//            for _ in 0..<2 {
//                let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
//                    return unaligned_copy_switch_race(
//                        fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
//                }
//                if overwriteSucceeded {
//                    overwroteOne = true
//                    break
//                }
//                print("try again?!")
//            }
//            guard overwroteOne else {
//                sendImportMessage(.failure("can't overwrite"))
//                return
//            }
//        }
//        updateProgress(total: false, progress: Double(fontData.count))
//        sendImportMessage(.success)
//        print(Date())
//    }
//    
//    func sendImportMessage(_ message: ProgressManager.ImportStatus) {
//        Task { @MainActor in
//            ProgressManager.shared.importResults.append(message)
//        }
//    }
//    
//    func updateProgress(total: Bool, progress: Double) {
//        Task { @MainActor in
//            if total {
//                ProgressManager.shared.totalProgress = progress
//            } else {
//                ProgressManager.shared.completedProgress = progress
//            }
//        }
//    }
//    
//    func dumpCurrentFont() {
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
//            0
//        ].path
//        let pathToTargetFont = documentDirectory + "/SFUI_dump.ttf"
//        let pathToRealTargetFont = "/System/Library/Fonts/CoreUI/SFUI.ttf"
//        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTargetFont))
//        try! origData.write(to: URL(fileURLWithPath: pathToTargetFont))
//    }
//    
//    func overwriteWithCustomFont(
//        name: String,
//        targetPaths: [String]?
//    ) async {
//        let documentDirectory = FileManager.default.urls(
//            for: .documentDirectory,
//            in: .userDomainMask
//        )[0]
//        
//        let fontURL = documentDirectory.appendingPathComponent(name)
//        guard FileManager.default.fileExists(atPath: fontURL.path) else {
//            await MainActor.run {
//                ProgressManager.shared.message = "No custom font imported"
//            }
//            return
//        }
//        
//        if let targetPaths {
//            for path in targetPaths {
//                if (access(path, F_OK) == 0) {
//                    await overwriteWithFont(
//                        fontURL: fontURL,
//                        pathToTargetFont: path
//                    )
//                }
//            }
//        } else {
//            await MainActor.run {
//                ProgressManager.shared.message = "Either targetName or targetNames must be provided"
//            }
//        }
//    }
//    
//    enum TTCRepackMode {
//        case woff2
//        case firstFontOnly
//    }
//    
//    func importCustomFontImpl(
//        fileURL: URL,
//        targetURL: URL,
//        ttcRepackMode: TTCRepackMode = .woff2
//    ) async -> String? {
//        // read first 16k of font
//        try? FileManager.default.removeItem(at: targetURL)
//        try! FileManager.default.copyItem(at: fileURL, to: targetURL)
//        return nil
//    }
//}
