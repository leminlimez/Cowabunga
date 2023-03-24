//
//  SettingsCustomizerManager.swift
//  Cowabunga
//
//  Created by lemin on 3/5/23.
//

import SwiftUI
import MacDirtyCowSwift

class SettingsCustomizerManager {
    // get the directory of the preferences
    private static func getSettingsDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Settings_Customizer")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the settings directory: \(error.localizedDescription)")
        }
        return nil
    }
    
    public static func removeImage() throws {
        guard let url: URL = getSettingsDirectory() else { throw "Could not get save url" }
        let imgURL = url.appendingPathComponent("SettingsImage@3x.png")
        if FileManager.default.fileExists(atPath: imgURL.path) {
            try FileManager.default.removeItem(at: imgURL)
        }
        let imgURL2 = url.appendingPathComponent("SettingsImageRaw.png")
        if FileManager.default.fileExists(atPath: imgURL2.path) {
            try FileManager.default.removeItem(at: imgURL2)
        }
    }
    
    public static func getImage(_ raw: Bool = true) -> UIImage? {
        do {
            guard let url: URL = getSettingsDirectory() else { throw "Could not get save url" }
            return UIImage(data: try Data(contentsOf: url.appendingPathComponent(raw ? "SettingsImageRaw.png" : "SettingsImage@3x.png")))
        } catch {
            return nil
        }
    }
    
    public static func saveImage(_ image: UIImage, newScale: Double = -1) throws {
        let size = newScale == -1 ? image.size : CGSize(width: CGFloat(990*(newScale/100)), height: CGFloat((image.size.height/image.size.width)*(990*(newScale/100))))
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // write the png
        guard let png = newImage?.pngData() else { throw "No png data" }
        guard let url: URL = getSettingsDirectory() else { throw "Could not get save url" }
        try png.write(to: url.appendingPathComponent(newScale == -1 ? "SettingsImageRaw.png" : "SettingsImage@3x.png"))
    }
    
    private static func removePropertyFromTable(_ isHS: Bool, dict: [[String: Any]]) -> [[String: Any]] {
        var newDict: [[String: Any]] = dict
        for (i, item) in dict.enumerated() {
            if !isHS && ((item["bundle"] != nil && (item["bundle"] as? String == "ClassroomSettings" || item["bundle"] as? String == "ClassKitSettings")) || (item["id"] != nil && (item["id"] as? String == "TRANSLATE"))) {
                newDict.remove(at: i)
            } else if isHS && item["id"] != nil {
                let currentDevice = UIDevice.current.userInterfaceIdiom
                if item["id"] as? String == "HOME_SCREEN_DOCK" && currentDevice == .phone {
                    newDict.remove(at: i)
                    return newDict
                } else if item["id"] as? String == "HOME_SCREEN" && currentDevice == .pad {
                    newDict.remove(at: i)
                    return newDict
                }
            }
        }
        return newDict
    }
    
    public static func changeLanguageLabels(restoring: Bool) throws {
        var lang: String = Locale.current.identifier
        if !FileManager.default.fileExists(atPath: "/System/Library/PrivateFrameworks/PreferencesUI.framework/\(lang).lproj/Settings~iphone.strings") {
            lang = String(lang.split(separator: "_").first!)
        }
        
        let filePath = "/System/Library/PrivateFrameworks/PreferencesUI.framework/\(lang).lproj/Settings~iphone.strings"
        let filePath_iOS16 = "/System/Library/PrivateFrameworks/PreferencesUI.framework/Settings.loctable"
        guard let url: URL = getSettingsDirectory() else { throw "Could not get save url" }
        
        if FileManager.default.fileExists(atPath: filePath) {
            let backupFolderURL = url.appendingPathComponent("\(lang)_lproj")
            if !FileManager.default.fileExists(atPath: backupFolderURL.path) {
                try FileManager.default.createDirectory(at: backupFolderURL, withIntermediateDirectories: false)
            }
            let backupURL = backupFolderURL.appendingPathComponent("Settings~iphone.strings")
            if !FileManager.default.fileExists(atPath: backupURL.path) {
                let backupData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                try backupData.write(to: backupURL)
            }
            
            let plistData = try Data(contentsOf: backupURL)
            
            if restoring {
                try MDC.overwriteFile(at: filePath, with: plistData)
            } else {
                var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                
                for (k, v) in plist {
                    if let _ = v as? String {
                        plist[k] = " "
                    }
                }
                
                let newData = try addEmptyData(matchingSize: plistData.count, to: plist)
                try MDC.overwriteFile(at: filePath, with: newData)
            }
            
        } else if FileManager.default.fileExists(atPath: filePath_iOS16) {
            let backupURL = url.appendingPathComponent("Settings.loctable")
            if !FileManager.default.fileExists(atPath: backupURL.path) {
                let backupData = try Data(contentsOf: URL(fileURLWithPath: filePath_iOS16))
                try backupData.write(to: backupURL)
            }
            
            let plistData = try Data(contentsOf: backupURL)
            if restoring {
                try MDC.overwriteFile(at: filePath_iOS16, with: plistData)
            } else {
                var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                
                for (lang, _) in plist {
                    if lang != "LocProvenance", var langPlist = plist[lang] as? [String: Any] {
                        for (k, v) in langPlist {
                            if let _ = v as? String {
                                langPlist[k] = " "
                            }
                        }
                        plist[lang] = langPlist
                    }
                }
                let newData = try addEmptyData(matchingSize: plistData.count, to: plist)
                try MDC.overwriteFile(at: filePath_iOS16, with: newData)
            }
        } else {
            throw "Settings language file for \(lang) not found!"
        }
    }
    
    public static func apply() throws {
        // get the preferences
        let removesIcons: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_RemoveIcons")
        let removesLabels: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_RemoveLabels")
        let removesPreviews: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_RemovePreviews")
        let useSettingsFootnote: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_UsesFootnote")
        let settingsFootnote: String = UserDefaults.standard.string(forKey: "SETTINGS_Footnote") ?? ""
        
        guard let url: URL = getSettingsDirectory() else { throw "Could not get save url" }
        let imgURL = url.appendingPathComponent("SettingsImage@3x.png")
        let hasImage = FileManager.default.fileExists(atPath: url.appendingPathComponent("SettingsImageRaw.png").path)
        let imageScale: Double = UserDefaults.standard.double(forKey: "SETTINGS_ImageScale")
        
        if hasImage {
            // create the image with the user scale
            try saveImage(getImage()!, newScale: imageScale)
        }
        
        if (!removesIcons && !removesLabels && !removesPreviews && !hasImage) && (!useSettingsFootnote || settingsFootnote == "") {
            try changeLanguageLabels(restoring: true)
            // nothing is in use, so revert
            let backupURL = url.appendingPathComponent("Settings.plist")
            let filePath = "/System/Library/PrivateFrameworks/PreferencesUI.framework/Settings.plist"
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try MDC.overwriteFile(at: filePath, with: try Data(contentsOf: backupURL))
            }
            return
        }
        
        // get a backup
        let backupURL = url.appendingPathComponent("Settings.plist")
        let filePath = "/System/Library/PrivateFrameworks/PreferencesUI.framework/Settings.plist"
        if !FileManager.default.fileExists(atPath: backupURL.path) {
            try Data(contentsOf: URL(fileURLWithPath: filePath)).write(to: backupURL)
        }
        
        let plistData = try Data(contentsOf: backupURL)
        
        var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        
        // remove classroom because lol
        var items = plist["items"] as! [[String: Any]]
        // remove unneeded variables
        items = removePropertyFromTable(false, dict: items)
        items = removePropertyFromTable(true, dict: items)
        
        if removesLabels {
            try changeLanguageLabels(restoring: false)
        } else {
            try changeLanguageLabels(restoring: true)
        }
        
        for (i, item) in items.enumerated() {
            // remove icons
            if removesIcons {
                items[i].removeValue(forKey: "iconCache")
            }
            // remove labels
            if removesLabels {
                if item["label"] != nil {
                    items[i]["label"] = " "
                }
            }
            // remove previews
            if removesPreviews {
                items[i].removeValue(forKey: "get")
            }
        }
        
        // footnote
        if useSettingsFootnote && settingsFootnote != "" {
            let footerDict: [String: Any] = [
                "cell": "PSGroupCell",
                "footerAlignment": Int(1),
                "footerText": settingsFootnote
            ]
            items.insert(footerDict, at: 2)
        }
        
        // image
        if hasImage {
            let imgDict: [String: Any] = [
                "height": Int(getImage(false)!.size.height/3),
                "icon": imgURL.path
            ]
            items.insert(imgDict, at: 1)
        }
        
        plist["items"] = items
        // create the plist
        let newData = try addEmptyData(matchingSize: plistData.count, to: plist)
        
        if newData.count != plistData.count {
            throw "Size does not match original file!\nOriginal: \(plistData.count) bytes\nNew: \(newData.count) bytes"
        }
        
        // write the plist
        try MDC.overwriteFile(at: filePath, with: newData)
    }
}
