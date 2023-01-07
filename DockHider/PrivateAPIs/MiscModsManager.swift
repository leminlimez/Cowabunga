//
//  MiscModsManager.swift
//  DockHider
//
//  Created by lemin on 1/7/23.
//

import Foundation

func getSystemVersion() -> String {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")) else { return "nil" }
    guard let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { return "nil" }
    
    // read the value
    if plist["ProductVersion"] != nil {
        return plist["ProductVersion"] as! String
    }
    
    // no value was found
    return "nil"
}

func setProductVersion(newVersion: String, completion: @escaping (Bool) -> Void) {
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
