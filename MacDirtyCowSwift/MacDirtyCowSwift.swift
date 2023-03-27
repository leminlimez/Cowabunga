//
//  MacDirtyCowSwift.swift
//  MacDirtyCowSwift
//
//  Created by sourcelocation on 08/02/2023.
//

import Foundation
import UIKit

public class MDC {
    public enum MDCOverwriteError: Error, LocalizedError {
        case unknown
        case ram
        case corruption
        
        public var errorDescription: String? {
            switch self {
            case .unknown:
                return "MacDirtyCow exploit failed. Restart the app and try again."
            case .ram:
                return "Cowabunga ran out of memory and for your safety disabled overwriting files using MacDirtyCow. Please close some apps running in background, reopen Cowabunga and try again."
            case .corruption:
                return "⚠️IMPORTANT⚠️\nMacDirtyCow corrupted an asset catalog. This will lead to a bootloop if the steps are not followed. FOLLOW CAREFULLY: Close all your background apps, then reopen Cowabunga for fixing. Then you can try again."
            }
        }
    }
    
    public static var isMDCSafe: Bool = true
    
    static var junk: [String] = []
    
    /// unlockDataAtEnd - Unlocked the data at overwrite end. Used when replacing files inside app bundle
    public static func overwriteFile(at path: String, with data: Data, unlockDataAtEnd: Bool = false, multipleIterations: Bool = false) throws {
//        junk.append(String(repeating: "a",  count: 50_000_000))
        
        if !isMDCSafe {
            throw MDCOverwriteError.ram
        }
        if multipleIterations {
            for i in 0...2 {
                print("Running mdc i=\(i)")
                try overwriteFileWithDataImpl(originPath: path, replacementData: data, unlockDataAtEnd: unlockDataAtEnd)
            }
        } else {
            try overwriteFileWithDataImpl(originPath: path, replacementData: data, unlockDataAtEnd: unlockDataAtEnd)
        }
    }
    
    public static func toggleCatalogCorruption(at path: String, corrupt: Bool) throws {
        let fd = open(path, O_RDONLY | O_CLOEXEC)
        guard fd != -1 else { throw "Could not open target file" }
        defer { close(fd) }
        
        let buffer = UnsafeMutablePointer<Int>.allocate(capacity: 0x4000)
        let n = read(fd, buffer, 0x4000)
        var byteArray = [UInt8](Data(bytes: buffer, count: n))
        
        
        let treeBytes: [UInt8] = [0,0,0,0, 0x74,0x72,0x65,0x65, 0,0,0]
        let corruptBytes: [UInt8] = [67, 111, 114, 114, 117, 112, 116, 84, 104, 105, 76]
        
        let findBytes = corrupt ? treeBytes : corruptBytes
        let replaceBytes = corrupt ? corruptBytes : treeBytes
        
        var startIndex = 0
        while startIndex <= byteArray.count - findBytes.count {
            let endIndex = startIndex + findBytes.count
            let subArray = Array(byteArray[startIndex..<endIndex])
            
            if subArray == findBytes {
                byteArray.replaceSubrange(startIndex..<endIndex, with: replaceBytes)
                startIndex += replaceBytes.count
            } else {
                startIndex += 1
            }
        }
        
        let overwriteSucceeded = byteArray.withUnsafeBytes { dataChunkBytes in
            return unaligned_copy_switch_race(
                fd, 0, dataChunkBytes.baseAddress, dataChunkBytes.count, true)
        }
        print("overwriteSucceeded = \(overwriteSucceeded)")
    }
}


extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
