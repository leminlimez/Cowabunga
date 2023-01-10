//
//  MiscModsManager.swift
//  DockHider
//
//  Created by lemin on 1/7/23.
//

import Foundation

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
    
    // find the value
    return getDictValue(plist, key)
}

func getDictValue(_ dict: [String: Any], _ key: String) -> String {
    for (k, v) in dict {
        if k == key {
            return dict[k] as! String
        } else if let subDict = v as? [String: Any] {
            return getDictValue(subDict, key)
        }
    }
    print("Could not find value")
    return "nil"
}

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

func setPlistValue(plistPath: String, backupName: String, key: String, newValue: String, completion: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
        let stringsData = try! Data(contentsOf: URL(fileURLWithPath: plistPath))
        
        let plist = try! PropertyListSerialization.propertyList(from: stringsData, options: [], format: nil) as! [String: Any]
        // open plist
        /*guard let data = try? Data(contentsOf: URL(fileURLWithPath: plistPath)) else {
            completion(false)
            return
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else {
            completion(false)
            return
        }*/
        
        // modify value
        let newPlist = changeDictValue(plist, key, newValue)
        
        // overwrite the plist
        let newData = try! PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
        
        let succeeded = overwriteFileWithDataImpl(originPath: plistPath, backupName: backupName, replacementData: newData)
        DispatchQueue.main.async {
            completion(succeeded)
        }
    }
}
