//
//  MiscModsManager.swift
//  Cowabunga
//
//  Created by lemin on 1/7/23.
//

import Foundation
import SwiftUI

func setProductVersion(newVersion: String, completion: @escaping (Bool) -> Void) {
    // this code is because I nearly bootlooped my phone with the later function
    DispatchQueue.global(qos: .userInteractive).async {
        let filePath: String = "/System/Library/CoreServices/SystemVersion.plist"
        // open plist
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            completion(false)
            return
        }
        guard var plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else {
            completion(false)
            return
        }
        
        // modify value
        plist["ProductVersion"] = newVersion
        
        // overwrite the plist
        guard let plistData = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) else {
            completion(false)
            return
        }
        let succeeded = overwriteFileWithDataImpl(originPath: filePath, backupName: "CoreServices/SystemVersion.plist", replacementData: plistData)
        DispatchQueue.main.async {
            completion(succeeded)
        }
    }
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

func setPlistValue(plistPath: String, backupName: String, key: String, value: String, completion: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
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
                
                let succeeded = overwriteFileWithDataImpl(originPath: plistPath, backupName: backupName, replacementData: newData)
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            } else {
                // temporary to create a log for me to debug
                do {
                    try stringsData.write(to: URL.documents.appendingPathComponent("OriginalMobilegestalt.plist"))
                    try newData.write(to: URL.documents.appendingPathComponent("UpdatedMobilegestalt.plist"))
                } catch {
                    UIApplication.shared.alert(body: "ERROR CREATING LOGS! Please notify lemin")
                }
                UIApplication.shared.alert(body: "Size did not match! (New size: " + String(newData.count) + ", Old size: " + String(originalSize) + ")")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        } catch {
            print(error.localizedDescription)
            UIApplication.shared.alert(body: "Error serializing the new data.")
        }
    }
}

func setPlistValueInt(plistPath: String, backupName: String, key: String, value: Int, completion: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
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
            let succeeded = overwriteFileWithDataImpl(originPath: plistPath, backupName: backupName, replacementData: newData)
            DispatchQueue.main.async {
                completion(succeeded)
            }
        } else {
            // too big
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}

func setCarrierName(newName: String, completion: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
        do {
            // Credit: TrollTools for process
            // get the carrier files
            for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Carrier Bundles/Overlay/"), includingPropertiesForKeys: nil) {
                guard let plistData = try? Data(contentsOf: url) else { continue }
                guard var plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String:Any] else { continue }
                let originalSize = plistData.count
                if originalSize < 30000 {
                    // modify values
                    if var images = plist["StatusBarImages"] as? [[String: Any]] {
                        for var (i, image) in images.enumerated() {
                            image["StatusBarCarrierName"] = newName
                            
                            images[i] = image
                        }
                        plist["StatusBarImages"] = images
                    }
                    
                    // remove unnecessary parameters
                    //plist.removeValue(forKey: "CarrierName")
                    plist.removeValue(forKey: "CarrierBookmarks")
                    //plist.removeValue(forKey: "StockSymboli")
                    plist.removeValue(forKey: "MyAccountURL")
                    //plist.removeValue(forKey: "HomeBundleIdentifier")
                    plist.removeValue(forKey: "MyAccountURLTitle")
                    
                    // create the new data
                    guard var newData = try? PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0) else { continue }
                    
                    // add data if too small
                    // while loop to make data match because recursive function didn't work
                    // very slow, will hopefully improve
                    var newDataSize = newData.count
                    var added = 1
                    while newDataSize < originalSize {
                        plist.updateValue(String(repeating: "#", count: added), forKey: "MyAccountURLTitle")
                        added += 1
                        //plist["MyAccountURLTitle"] = plist["MyAccountURLTitle"] as! String + "#"
                        newData = try! PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
                        newDataSize = newData.count
                    }
                    // apply
                    // uses haxi0's poc because it is over 16 kb
                    try FSOperation.perform(.writeData(url: url, data: newData), rootHelperConf: RootConf.shared)
                }
            }
            
            // send back whether or not at least one was successful
            DispatchQueue.main.async {
                completion(true)
            }
        } catch {
            // an error occurred
            print("An error occurred with setting the carrier name")
            DispatchQueue.main.async {
                completion(false)
            }
        }
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
