//
//  PasscodeKeyFaceChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 17.10.2022.
//

import UIKit
import ZIPFoundation

enum KeySizeState: String {
    case small = "Small"
    case big = "Big"
    case custom = "Custom"
}

enum KeySize: Int {
    case small = 150
    case big = 225
}

enum PasscodeSizeLimit: Int { // the limits of the custom size
    case min = 50
    case max = 2500
}

class PasscodeKeyFaceManager {

    static func setFace(_ image: UIImage, for n: Int, keySize: CGFloat, customX: CGFloat, customY: CGFloat) throws {
        // this part could be cleaner
        var usesCustomSize = true
        var sizeToUse: CGFloat = 0
        if keySize > 0 {
            sizeToUse = keySize
            usesCustomSize = false
        }
        
        let size = usesCustomSize ? CGSize(width: customX, height: customY) : CGSize(width: sizeToUse, height: sizeToUse)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let url = try getURL(for: n)
        guard let png = newImage?.pngData() else { throw "No png data" }
        try png.write(to: url)
    }
    
    static func removeAllFaces() throws {
        let fm = FileManager.default
        
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(), includingPropertiesForKeys: nil) {
            let size = CGSize(width: KeySize.small.rawValue, height: KeySize.small.rawValue)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            UIImage().draw(in: CGRect(origin: .zero, size: size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let png = newImage?.pngData() else { throw "No png data" }
            try png.write(to: imageURL)
        }
    }
    
    static func getSupportURL() throws -> URL {
        let fm = FileManager.default
        
        lazy var appSupportURL: URL = {
            let urls = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            return urls[0]
        }()
        
        var isDir: ObjCBool = false
        if !fm.fileExists(atPath: appSupportURL.path, isDirectory: &isDir) {
            do {
                try fm.createDirectory(atPath: appSupportURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        return appSupportURL
    }
    
    static func getNumberFromURL(url: URL) throws -> Int {
        for i in 0...9 {
            if url.lastPathComponent.contains(String(i)) {
                return i
            }
        }
        return -1
    }
    
    static func setFacesFromTheme(_ url: URL, keySize: CGFloat, customX: CGFloat, customY: CGFloat) throws {
        let fm = FileManager.default
        let teleURL = try telephonyUIURL()
        let supportURL = try getSupportURL()
        let defaultSize = getDefaultFaceSize()
        
        var finalURL = url
        var isTemp: Bool = false
        
        var sizeMultiplier: Double = 1
        
        if url.lastPathComponent.contains(".passthm") {
            try fm.unzipItem(at: url, to: supportURL)
            for folder in (try? fm.contentsOfDirectory(at: supportURL, includingPropertiesForKeys: nil)) ?? [] {
                if folder.lastPathComponent.contains("TelephonyUI") {
                    finalURL = folder
                    isTemp = true
                    
                    if fm.fileExists(atPath: folder.path + "/_small") && defaultSize >= KeySize.big.rawValue - 10 {
                        // set the size for bigger keys
                        sizeMultiplier = 287/202//Double(KeySize.big.rawValue - 12)/Double(KeySize.small.rawValue)
                        try fm.removeItem(atPath: folder.path + "/_small")
                    } else if fm.fileExists(atPath: folder.path + "/_big") && defaultSize <= KeySize.small.rawValue + 10 {
                        // set size for smaller keys
                        sizeMultiplier = 202/287//Double(KeySize.small.rawValue + 9)/Double(KeySize.big.rawValue)
                        try fm.removeItem(atPath: folder.path + "/_big")
                    }
                }
            }
        }
        for imageURL in (try? fm.contentsOfDirectory(at: finalURL, includingPropertiesForKeys: nil)) ?? [] {
            // determine if it is a number
            var number: Int = try getNumberFromURL(url: imageURL)
            if number != -1 {
                let img = UIImage(contentsOfFile: imageURL.path)
                var newSize: [CGFloat] = [CGFloat(Double(img?.size.width ?? 150) * sizeMultiplier), CGFloat(Double(img?.size.height ?? 150) * sizeMultiplier)]
                // check the sizes and set it
                if keySize == -1 {
                   // replace sizes if a custom size is chosen
                   // overrides custom sizes from theme
                   newSize[0] = customX
                   newSize[1] = customY
                }
                
                // verify that the size of the images is under the limit
                if Int(newSize[0]) < PasscodeSizeLimit.min.rawValue {
                    newSize[0] = CGFloat(PasscodeSizeLimit.min.rawValue)
                } else if Int(newSize[0]) > PasscodeSizeLimit.max.rawValue {
                    newSize[0] = CGFloat(PasscodeSizeLimit.max.rawValue)
                }
                
                if Int(newSize[1]) < PasscodeSizeLimit.min.rawValue {
                    newSize[1] = CGFloat(PasscodeSizeLimit.min.rawValue)
                } else if Int(newSize[1]) > PasscodeSizeLimit.max.rawValue {
                    newSize[1] = CGFloat(PasscodeSizeLimit.max.rawValue)
                }
                
                let size = CGSize(width: newSize[0], height: newSize[1])
                UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
                img!.draw(in: CGRect(origin: .zero, size: size))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let newURL = try getURL(for: number)
                guard let png = newImage?.pngData() else { continue }
                try png.write(to: teleURL.appendingPathComponent(newURL.lastPathComponent))
            }
        }
        if isTemp {
            // delete the files when done
            try fm.removeItem(at: finalURL)
            return
        }
    }
    
    static func exportFaceTheme() throws -> URL? {
        let fm = FileManager.default
        let teleURL = try telephonyUIURL()
        
        var archiveURL: URL?
        var error: NSError?
        let coordinator = NSFileCoordinator()
        
        var userSize: String = getDefaultFaceSize() <= KeySize.small.rawValue + 10 ? "small" : "big"
        
        // create a file to be exported stating the size
        let sizeFile = teleURL.path + "/_"+userSize
        fm.createFile(atPath: sizeFile, contents: nil)
        
        coordinator.coordinate(readingItemAt: teleURL, options: [.forUploading], error: &error) { (zipURL) in
            let tmpURL = try! fm.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: zipURL,
                create: true
            ).appendingPathComponent("exported_theme.passthm")
            try! fm.moveItem(at: zipURL, to: tmpURL)
            archiveURL = tmpURL
        }
        // delete the size file
        try fm.removeItem(atPath: sizeFile)
        
        if let archiveURL = archiveURL {
            return archiveURL
        } else {
            throw "There was an error exporting"
        }
    }
    
    static func reset() throws {
        let fm = FileManager.default
        let defaults = UserDefaults.standard
        for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches/"), includingPropertiesForKeys: nil) {
            if url.lastPathComponent.contains("TelephonyUI") {
                try fm.removeItem(at: url)
                // reset default size
                defaults.removeObject(forKey: "passcodeFaceSize")
            }
        }
    }
    
    static func getFaces() throws -> [UIImage?] {
        return try [0,1,2,3,4,5,6,7,8,9].map { try getFace(for: $0) }
    }
    
    static func getFace(for n: Int) throws -> UIImage? {
        return UIImage(data: try Data(contentsOf: getURL(for: n)))
    }
    
    static func getURL(for n: Int) throws -> URL { // O(n^2), but works
        let fm = FileManager.default
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(), includingPropertiesForKeys: nil) {
            if imageURL.path.contains("-\(n)-") {
                return imageURL
            }
        }
        throw "Passcode face #\(n) couldn't be found."
    }
    
    static func telephonyUIURL() throws -> URL {
        guard let url = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches/"), includingPropertiesForKeys: nil)
            .first(where: { url in url.lastPathComponent.contains("TelephonyUI") }) else { throw "TelephonyUI folder not found. Have the caches been generated? Reset faces in app and try again." }
                   return url
    }
    
    // user defaults stuff
    static func getDefaultFaceSize() -> Int {
        let defaults = UserDefaults.standard
        var size = defaults.integer(forKey: "passcodeFaceSize")
        
        // if it exists, return it
        if size != 0 {
            return size
        }
        
        // if it doesn't, create it
        do {
            let teleURL = try telephonyUIURL()
            let fm = FileManager.default
            size = Int(UIImage(contentsOfFile: try fm.contentsOfDirectory(at: teleURL, includingPropertiesForKeys: nil)[0].path)?.size.height ?? 150)
            // set the value and return
            defaults.set(size, forKey: "passcodeFaceSize")
            return size
        } catch {
            // just set the defaults to 150
            defaults.set(150, forKey: "passcodeFaceSize")
            return 150
        }
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
