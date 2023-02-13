//
//  PasscodeKeyFaceChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 17.10.2022.
//

import UIKit
import ZIPFoundation
import SwiftUI

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

enum TelephonyDirType {
    case passcode
    case dialer
}

class PasscodeKeyFaceManager {
    private static var savedDialerURL: String = ""
    public static let CharacterTable: [Character] = ["0","1","2","3","4","5","6","7","8","9", "*", "#"]

    static func setFace(_ image: UIImage, for n: Character, _ dir: TelephonyDirType, colorScheme: ColorScheme, keySize: CGFloat, customX: CGFloat, customY: CGFloat) throws {
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
        
        let url = try getURL(for: n, mask: (colorScheme == .light), dir)
        guard let png = newImage?.pngData() else { throw "No png data" }
        try png.write(to: url)
    }
    
    static func removeAllFaces(_ dir: TelephonyDirType) throws {
        let fm = FileManager.default
        
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(dir), includingPropertiesForKeys: nil) {
            let size = CGSize(width: KeySize.small.rawValue, height: KeySize.small.rawValue)
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            UIImage().draw(in: CGRect(origin: .zero, size: size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let png = newImage?.pngData() else { throw "No png data" }
            try png.write(to: imageURL)
        }
    }
    
    static func getCharacterFromURL(url: URL) throws -> Character {
        for (_, c) in CharacterTable.enumerated() {
            if url.lastPathComponent.contains(c) {
                return c
            }
        }
        return "h"
    }
    
    static func themeHasMasks(_ url: URL) -> Bool {
        let fm = FileManager.default
        do {
            for img in (try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) {
                if img.lastPathComponent.contains("mask") {
                    return true
                }
            }
            return false
        } catch {
            return false
        }
    }
    
    static func setFacesFromTheme(_ url: URL, _ dir: TelephonyDirType, colorScheme: ColorScheme, keySize: CGFloat, customX: CGFloat, customY: CGFloat) throws {
        let fm = FileManager.default
        let teleURL = try telephonyUIURL(dir)
        let defaultSize = getDefaultFaceSize()
        
        var finalURL = url
        var isTemp: Bool = false
        
        var sizeMultiplier: Double = 1
        
        if url.lastPathComponent.contains(".passthm") {
            let unzipURL = fm.temporaryDirectory.appendingPathComponent("passthm_unzip")
            try? fm.removeItem(at: unzipURL)
            try fm.unzipItem(at: url, to: unzipURL)
            for folder in (try? fm.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: nil)) ?? [] {
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
        let applyToMasks: Bool = ((colorScheme == .light) && !themeHasMasks(finalURL))
        for imageURL in (try? fm.contentsOfDirectory(at: finalURL, includingPropertiesForKeys: nil)) ?? [] {
            // determine if it is a number
            let char: Character = try getCharacterFromURL(url: imageURL)
            if char != "h" {
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
                
                let isMask: Bool = (applyToMasks || imageURL.path.contains("mask"))
                
                var newURL: URL
                do {
                    // guard let errored here for some reason, so i need this
                    newURL = try getURL(for: char, mask: isMask, dir)
                } catch {
                    continue
                }
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
    
    static func exportFaceTheme(_ dir: TelephonyDirType) throws -> URL? {
        let fm = FileManager.default
        let teleURL = try telephonyUIURL(dir)
        
        var archiveURL: URL?
        var error: NSError?
        let coordinator = NSFileCoordinator()
        
        let userSize: String = getDefaultFaceSize() <= KeySize.small.rawValue + 10 ? "small" : "big"
        
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
    
    static func reset(_ dir: TelephonyDirType) throws {
        let fm = FileManager.default
        let defaults = UserDefaults.standard
        try fm.removeItem(at: try telephonyUIURL(dir))
        if dir == .passcode {
            defaults.removeObject(forKey: "passcodeFaceSize")
        }
    }
    
    static func getFaces(_ dir: TelephonyDirType, colorScheme: ColorScheme) throws -> [UIImage?] {
        if dir == .passcode {
            return try ["0","1","2","3","4","5","6","7","8","9", "9", "9"].map { try getFace(for: $0, dir) }
        } else if dir == .dialer {
            return try ["0","1","2","3","4","5","6","7","8","9", "*", "#"].map { try getFace(for: $0, mask: (colorScheme == .light), dir) }
        } else {
            throw "Incorrect directory type"
        }
    }
    
    static func getFace(for n: Character, mask: Bool = false, _ dir: TelephonyDirType) throws -> UIImage? {
        return UIImage(data: try Data(contentsOf: getURL(for: n, mask: mask, dir)))
    }
    
    static func getURL(for n: Character, mask: Bool = false, _ dir: TelephonyDirType) throws -> URL { // O(n^2), but works
        let fm = FileManager.default
        for imageURL in try fm.contentsOfDirectory(at: try telephonyUIURL(dir), includingPropertiesForKeys: nil) {
            if imageURL.path.contains("-\(n)-") && ((mask && imageURL.path.contains("mask")) || (!mask && !imageURL.path.contains("mask"))) {
                return imageURL
            }
        }
        throw "Passcode face #\(n) couldn't be found."
    }
    
    static func getDialerDataURL() throws -> URL {
        if savedDialerURL != "" {
            return URL(fileURLWithPath: savedDialerURL)
        }
        /*let library = FBSApplicationLibrary()
        let info = library.applicationInfo(forBundleIdentifier: "com.hammerandchisel.discord")
        let containerPath = info?.dataContainerURL.resourceSpecifier*/
        
        let appDataPath = "/var/mobile/Containers/Data/Application"
        for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: appDataPath), includingPropertiesForKeys: []) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: try Data(contentsOf: url.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")), options: [], format: nil) as! [String: Any]
                if plist["MCMMetadataIdentifier"] != nil && plist["MCMMetadataIdentifier"]! as! String == "com.apple.mobilephone" {
                    savedDialerURL = url.path
                    return url
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        throw "Could not find mobile phone url"
    }
    
    static func telephonyUIURL(_ dir: TelephonyDirType) throws -> URL {
        if dir == .passcode {
            guard let url = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches/"), includingPropertiesForKeys: nil)
                .first(where: { url in url.lastPathComponent.contains("TelephonyUI") }) else { throw "TelephonyUI folder not found. Have the caches been generated? Reset faces in app and try again." }
            return url
        } else if dir == .dialer {
            let dialerURL = try getDialerDataURL()
            guard let url = try FileManager.default.contentsOfDirectory(at: dialerURL.appendingPathComponent("Library/Caches"), includingPropertiesForKeys: nil)
                .first(where: { url in url.lastPathComponent.contains("TelephonyUI") }) else { throw "TelephonyUI folder not found. Have the caches been generated? Reset faces in app and try again." }
            return url
        } else {
            throw "Incorrect directory type"
        }
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
            let teleURL = try telephonyUIURL(TelephonyDirType.passcode)
            let fm = FileManager.default
            size = Int(UIImage(contentsOfFile: try fm.contentsOfDirectory(at: teleURL, includingPropertiesForKeys: nil)[0].path)?.size.height ?? 150)
            // set the value and return
            defaults.set(size, forKey: "passcodeFaceSize")
            return size
        } catch {
            // just set the defaults to 150
            print("Could not get sizes")
            print(error.localizedDescription)
            //defaults.set(150, forKey: "passcodeFaceSize")
            return 150
        }
    }
    
    // get the directory of the saved passcodes
    static func getPasscodesDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Saved_Passcodes")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the saved passcodes directory")
        }
        return nil
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
