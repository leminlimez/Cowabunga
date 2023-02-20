//
//  MiscModsManager.swift
//  Cowabunga
//
//  Created by lemin on 1/7/23.
//

import Foundation
import SwiftUI
import MacDirtyCowSwift

enum SettingsOptionType: String {
    case textbox = "PSEditTextCell"
    case toggle = "PSSwitchCell"
    case slider = "PSSliderCell"
    case button = "PSButtonCell"
}

struct SettingsPageOption: Identifiable {
    var id = UUID()
    var type: SettingsOptionType
    var defaultValue: Any
    var key: String
    var placeholder: String?
    var label: String
    var editingFilePath: String
}

// settings pages
let settingsOptions: [SettingsPageOption] = [
    // LS Footnote
    //.init(type: SettingsOptionType.textbox, defaultValue: "", key: "LockScreenFootnote", placeholder: "Footnote", label: "Lock Screen Footnote", editingFilePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"),
    // Device Supervision
    //.init(type: SettingsOptionType.toggle, defaultValue: 0, key: "IsSupervised", label: "Device Supervised", editingFilePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"),
    // Organization Name
    //.init(type: SettingsOptionType.textbox, defaultValue: "", key: "OrganizationName", placeholder: "Organization", label: "Organization Name", editingFilePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"),
    // Don't Lock After Respring
    .init(type: SettingsOptionType.toggle, defaultValue: 0, key: "SBDontLockAfterCrash", label: "Don't Lock After Respring", editingFilePath: "com.apple.springboard"),
    // Numeric Wi-Fi Strength
    .init(type: SettingsOptionType.toggle, defaultValue: 0, key: "SBShowRSSI", label: "Numeric Wi-Fi Strength", editingFilePath: "com.apple.springboard"),
    // Numeric Cellular Strength
    //.init(type: SettingsOptionType.toggle, defaultValue: 0, key: "SBShowGSMRSSI", label: "Numeric Cellular Strength", editingFilePath: "com.apple.springboard")
]

func getValueInSystemVersionPlist(key: String) throws -> Any? {
    let filePath: String = "/System/Library/CoreServices/SystemVersion.plist"
    // open plist
    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
    guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "systemversion is corrupted." }
    guard let value = plist[key] else { throw "key \(key) not found in systemversion plist" }
    return value
}

func modifyScreenTime(enabled: Bool) throws {
    if enabled {
        // re enable if exists
        if FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/.BACKUP_com.apple.ScreenTimeAgent.plist") {
            let data = try Data(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/.BACKUP_com.apple.ScreenTimeAgent.plist"))
            try data.write(to: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist"))
            try FileManager.default.removeItem(at: URL(fileURLWithPath: "/var/mobile/Library/Preferences/.BACKUP_com.apple.ScreenTimeAgent.plist"))
        } else {
            throw "No screentime file backup found!"
        }
    } else {
        // remove the file
        let data = try Data(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist"))
        try data.write(to: URL(fileURLWithPath: "/var/mobile/Library/Preferences/.BACKUP_com.apple.ScreenTimeAgent.plist"))
        try FileManager.default.removeItem(at: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist"))
    }
}

func setValueInSystemVersionPlist(key: String, value: String) throws -> String {
    let filePath: String = "/System/Library/CoreServices/SystemVersion.plist"
    // open plist
    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
    guard var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "systemversion is corrupted." }
    
    // modify value
    guard let oldValue = plist[key] as? String else { throw "no \(key) value?" }
    plist[key] = value
    
    // overwrite the plist
    let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
    let succeeded = MDC.overwriteFile(at: filePath, with: plistData)
    guard succeeded else { throw "mdc exploit did not succeed while setting systemversion"}
    return oldValue
}

func getPlistValue(plistPath: String, key: String) -> String {
    // open plist
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: plistPath)) else {
        print("Could not get plist data!")
        return "nil"
    }
    guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
        print("Could not convert plist!")
        return "nil"
    }
    
    func getDictValue(_ dict: [String: Any], _ key: String) -> String {
        for (k, v) in dict {
            if k == key {
                return dict[k] as! String
            } else if let subDict = v as? [String: Any] {
                let temp: String = getDictValue(subDict, key)
                if temp != "nil" {
                    return temp
                }
            }
        }
        // did not find key in dictionary
        return "nil"
    }
    
    // find the value
    return getDictValue(plist, key)
}

func getPlistIntValue(plistPath: String, key: String) -> Int {
    // open plist
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: plistPath)) else {
        print("Could not get plist data!")
        return -1
    }
    guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
        print("Could not convert plist!")
        return -1
    }
    
    func getDictValue(_ dict: [String: Any], _ key: String) -> Int {
        for (k, v) in dict {
            if k == key {
                return dict[k] as! Int
            } else if let subDict = v as? [String: Any] {
                let temp: Int = getDictValue(subDict, key)
                if temp != -1 {
                    return temp
                }
            }
        }
        // did not find key in dictionary
        return -1
    }
    
    // find the value
    return getDictValue(plist, key)
}

func setPlistValue(plistPath: String, key: String, value: String) -> Bool {
    let stringsData = try! Data(contentsOf: URL(fileURLWithPath: plistPath))
    let originalSize = stringsData.count
    
    // open plist
    let plist = try! PropertyListSerialization.propertyList(from: stringsData, options: [], format: nil) as! [String: Any]
    func changeDictValue(_ dict: [String: Any], _ key: String, _ value: String) -> [String: Any] {
        var newDict = dict
        for (k, v) in dict {
            if k == key {
                newDict[k] = value
            } else if let subDict = v as? [String: Any] {
                newDict[k] = changeDictValue(subDict, key, value)
            }
        }
        return newDict
    }
    
    // modify value
    var newPlist = plist
    newPlist = changeDictValue(newPlist, key, value)
    
    // overwrite the plist
    do {
        let newData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
        
        if newData.count == originalSize {
            
            return MDC.overwriteFile(at: plistPath, with: newData)
        } else {
            // temporary to create a log for me to debug
            do {
                try stringsData.write(to: URL.documents.appendingPathComponent("OriginalMobilegestalt.plist"))
                try newData.write(to: URL.documents.appendingPathComponent("UpdatedMobilegestalt.plist"))
            } catch {
                UIApplication.shared.alert(body: "ERROR CREATING LOGS! Please notify lemin")
            }
            UIApplication.shared.alert(body: "Size did not match! (New size: " + String(newData.count) + ", Old size: " + String(originalSize) + ")")
            return false
        }
    } catch {
        print(error.localizedDescription)
        UIApplication.shared.alert(body: "Error serializing the new data.")
        return false
    }
}

func setPlistValueInt(plistPath: String, key: String, value: Int) -> Bool {
    let stringsData = try! Data(contentsOf: URL(fileURLWithPath: plistPath))
    
    // open plist
    let plist = try! PropertyListSerialization.propertyList(from: stringsData, options: [], format: nil) as! [String: Any]
    func changeDictValue(_ dict: [String: Any], _ key: String, _ value: Int) -> [String: Any] {
        var newDict = dict
        for (k, v) in dict {
            if k == key {
                newDict[k] = value
            } else if let subDict = v as? [String: Any] {
                newDict[k] = changeDictValue(subDict, key, value)
            }
        }
        return newDict
    }
    
    // modify value
    var newPlist = plist
    newPlist = changeDictValue(newPlist, key, value)
    
    // overwrite the plist
    let newData = try! PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
    if newData.count == stringsData.count {
        return MDC.overwriteFile(at: plistPath, with: newData)
    } else {
        // too big
        return false
    }
}

func setRegion() -> Bool {
    do {
        let plistPath: String = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
        let plistData = try Data(contentsOf: URL(fileURLWithPath: plistPath))
        let originalSize = plistData.count
        
        // open plist
        var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        
        func modifyKey(_ dict: [String: Any], _ key: String, newValue: String) -> [String: Any]? {
            if var firstLevel = dict["CacheExtra"] as? [String : Any], var secondLevel = firstLevel[key] as? String {
                secondLevel = newValue
                firstLevel[key] = secondLevel
                return firstLevel
            }
            return nil
        }
        
        // modify values
        let keysToChange: [String: String] = [
            "h63QSdBCiT/z0WU6rdQv6Q": "LL",
            "zHeENZu+wbg7PUprwNwBWg": "LL/A",
            "IMLaTlxS7ITtwfbRfPYWuA": "A"
        ]
        var succeeded = true
        for (k, val) in keysToChange {
            let newLevel = modifyKey(plist, k, newValue: val)
            if newLevel != nil {
                plist["CacheExtra"] = newLevel
            } else {
                print("Error with key " + k)
                succeeded = false
            }
        }
        
        if succeeded {
            // create the new data
            let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
            
            // check the size and apply
            if newData.count == originalSize {
                let succeeded = MDC.overwriteFile(at: plistPath, with: newData)
                if succeeded {
                    UIApplication.shared.alert(title: "Successfully applied region", body: "Respring and see if it worked")
                } else {
                    UIApplication.shared.alert(body: "Could not overwrite region file")
                }
                return succeeded
            } else {
                UIApplication.shared.alert(body: "The file sizes did not match!")
                return false
            }
        } else {
            UIApplication.shared.alert(body: "A value failed to apply")
            return false
        }
    } catch {
        print("An error occurred while setting region")
        UIApplication.shared.alert(body: "An error occurred while setting region")
        return false
    }
}

func addEmptyData(matchingSize: Int, to plist: [String: Any]) throws -> Data {
    var newPlist = plist
    // create the new data
    guard var newData = try? PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0) else { throw "Unable to get data" }
    // add data if too small
    // while loop to make data match because recursive function didn't work
    // very slow, will hopefully improve
    var newDataSize = newData.count
    var added = matchingSize - newDataSize
    if added < 0 {
        added = 1
    }
    var count = 0
    while newDataSize != matchingSize || count < 200 {
        count += 1
        if added < 0 {
            break
        }
        newPlist.updateValue(String(repeating: "#", count: added), forKey: "MdC")
        do {
            newData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
        } catch {
            newDataSize = -1
            break
        }
        newDataSize = newData.count
        if count < 5 {
            // max out this method at 5 if it isn't working
            added += matchingSize - newDataSize
        } else {
            if newDataSize > matchingSize {
                added -= 1
            } else if newDataSize < matchingSize {
                added += 1
            }
        }
    }

    return newData
}

//func addEmptyData(matchingSize: Int, to plist: [String: Any]) throws -> Data {
//    func getSize(of plist: [String: Any]) throws -> Int {
//        guard var data = try? PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0) else { throw "Unable to get data" }
//        return data.count
//    }
//    var newPlist = plist
//
//    let newPlistSize = try getSize(of: newPlist)
//    let difference = matchingSize - newPlistSize - 34
//    guard difference >= 0 else { throw "Difference in size between new plist and one to match cannot be negative" }
//
//    newPlist["MdC"] = String(repeating: "#", count: difference)
//    let newPlistSize1 = try getSize(of: newPlist)
//
//    return try PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
//}

func setCarrierName(newName: String) -> Bool {
    do {
        var succeededOnce: Bool = false
        // Credit: TrollTools for process
        // get the carrier files
        for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Carrier Bundles/Overlay/"), includingPropertiesForKeys: nil) {
            guard let plistData = try? Data(contentsOf: url) else { print("could not get data"); continue }
            guard var plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String:Any] else { print("Could not serialize"); continue }
            let originalSize = plistData.count
            // modify values
            if var images = plist["StatusBarImages"] as? [[String: Any]] {
                for (i, image) in images.enumerated() {
                    images[i]["StatusBarCarrierName"] = newName
                    
                    images[i] = image
                }
                plist["StatusBarImages"] = images
            }
            
            // remove unnecessary parameters
            plist.removeValue(forKey: "CarrierName")
            plist.removeValue(forKey: "CarrierBookmarks")
            plist.removeValue(forKey: "StockSymboli")
            plist.removeValue(forKey: "MyAccountURL")
            plist.removeValue(forKey: "HomeBundleIdentifier")
            plist.removeValue(forKey: "MyAccountURLTitle")
            
            guard let newData = try? addEmptyData(matchingSize: originalSize, to: plist) else { continue }
            
            if newData.count == originalSize {
                // apply
                if MDC.overwriteFile(at: url.path, with: newData) == true {
                    succeededOnce = true
                }
            }
        }
        
        // send back whether or not at least one was successful
        return succeededOnce
    } catch {
        // an error occurred
        return false
    }
}

func getCurrentDeviceSubType() -> Int {
    let currentSubType = getPlistIntValue(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", key: "ArtworkDeviceSubType")
    if currentSubType == -1 {
        // respring
        //respring()
    } else {
        // return
        return currentSubType
    }
    return -1
}

func getOriginalDeviceSubType() -> Int {
    let origSubType = UserDefaults.standard.integer(forKey: "OriginalDeviceSubType")
    if origSubType == 0 {
        // grab it and store it
        let currentSubType = getPlistIntValue(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", key: "ArtworkDeviceSubType")
        print(currentSubType)
        if currentSubType != -1 {
            UserDefaults.standard.set(currentSubType, forKey: "OriginalDeviceSubType")
            return currentSubType
        }
    }
    return origSubType
}

func togglePlistOption(plistPath: String, key: String, value: Any) throws {
    let url = URL(fileURLWithPath: plistPath)
    
    var plistData: Data
    if !FileManager.default.fileExists(atPath: url.path) {
        plistData = try PropertyListSerialization.data(fromPropertyList: [key: value], format: .xml, options: 0)
    } else {
        guard let data = try? Data(contentsOf: url), var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read plist" }
        plist[key] = value
        
        // Save plist
        plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
    }
    
    // write to file
    try plistData.write(to: url)
}

enum ShortcutAppMod {
    case deleteBanner
    case modifyAppClips
}

// modify the shortcut apps
func modifyShortcutApp(modifying: ShortcutAppMod, _ value: Bool = false) -> Bool {
    let path: String = "/var/mobile/Library/WebClips"
    // get the contents of the path
    do {
        var succeeded: Bool = true
        for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil) {
            //if !url.lastPathComponent.starts(with: ".DO-NOT-DELETE") {
                // get the info.plist
                let plistURL = url.appendingPathComponent("Info.plist")
                guard let plistData = try? Data(contentsOf: plistURL) else { print("could not get data"); continue }
                guard var plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String:Any] else { print("Could not serialize"); continue }
                
                // delete the property
                if modifying == ShortcutAppMod.deleteBanner {
                    // make sure it is an app and not a regular shortcut
                    if plist["ApplicationBundleIdentifier"] != nil && (plist["ApplicationBundleIdentifier"] as? String) != "" {
                        plist.removeValue(forKey: "ShortcutIdentifier")
                    }
                }
                
                if modifying == ShortcutAppMod.modifyAppClips {
                    plist.updateValue(value, forKey: "IsAppClip")
                }
                
                do {
                    // create the new data
                    let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                    // apply plist
                    succeeded = succeeded && MDC.overwriteFile(at: plistURL.path, with: newData)
                } catch {
                    print("Could not replace plist data: \(error.localizedDescription)")
                    succeeded = false
                }
            //}
        }
        return succeeded
    } catch {
        print("An error occurred when getting the shortcut directory: \(error.localizedDescription)")
        return false
    }
}

// creates a page in settings
func createSettingsPage() -> Bool {
    var itemsList: [[String: Any]] = [
    ]
    
    // create the pages
    for (_, page) in settingsOptions.enumerated() {
        var newDict: [String: Any] = [
            "cell": page.type.rawValue,
            "default": page.defaultValue,
            "defaults": page.editingFilePath,
            "key": page.key,
            "label": page.label
        ]
        if page.placeholder != nil {
            newDict["placeholder"] = page.placeholder
        }
        // append to plist
        itemsList.append(newDict)
    }
    
    let plist: [String: Any] = [
        "items": itemsList,
        "title": "Cowabunga Extra Tools"
    ]
    
    // modify the settings labels plist
    // broken because it becomes very large for some reason?
    /*do {
        let plistPath: String = "/System/Library/PrivateFrameworks/PreferencesUI.framework/Settings.plist"
        let plistData = try Data(contentsOf: URL(fileURLWithPath: plistPath))
        
        // open plist
        var settingsPlist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        
        // set the labels
        var items = settingsPlist["items"] as! [[String: Any]]
        for (i, itm) in items.enumerated() {
            if itm["label"] != nil {
                if itm["label"] as! String == "Classroom" {
                    items[i]["label"] = ""
                } else if itm["label"] as! String == "Photos" {
                    items[i]["label"] = "Cowabunga"
                }
            }
        }
        
        settingsPlist["items"] = items
        
        // write to the plist
        let newData = try PropertyListSerialization.data(fromPropertyList: settingsPlist, format: .xml, options: 0)
        // replace the data
        let _ = MDC.overwriteFile(at: plistPath, with: newData)
    } catch {
        print("Could not change labels!")
    }*/
    
    // convert to plist data
    do {
        let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        // replace the data
        var path: String
        if #available(iOS 16, *) {
            path = "/System/Library/PreferenceBundles/MobilePhoneSettings.bundle/Phone.plist"
        } else {
            path = "/System/Library/PreferenceBundles/MobileSlideShowSettings.bundle/Photos.plist"
        }
        return MDC.overwriteFile(at: path, with: newData)
    } catch {
        print("Could not get the data!")
        return false
    }
}
