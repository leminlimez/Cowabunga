//
//  ColorSwapManager.swift
//  Cowabunga
//
//  Created by lemin on 3/14/23.
//

import Foundation
import CoreImage

class ColorSwapManager {
    public static func setColor(url: URL, color: CIColor, blur: Int) throws -> Data {
        let plistData = try Data(contentsOf: url)
        if let originalPlist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
            var plist = setColor(list: originalPlist, color: color, blur: blur)
            let newData = try addEmptyData(matchingSize: plistData.count, to: plist)
            if newData.count == plistData.count {
                return newData
            } else {
                throw "File size does not match!!!\nNew: \(newData.count)\nOld: \(plistData.count)"
            }
        } else {
            throw "Error serializing original plist data!"
        }
    }
    
    public static func setColor(list: [String: Any], color: CIColor, blur: Int) -> [String: Any] {
        func changeValue(dict: [String: Any], keyName: String, newName: String, replacement: Any, remove: Bool = true, appends: Bool = false) -> [String: Any] {
            var newDict = dict
            for (k, _) in dict {
                if k == keyName {
                    if remove {
                        newDict[k] = nil
                        newDict[newName] = replacement
                    } else {
                        if appends, var repDict = dict[k] as? [String: Any] {
                            repDict[newName] = replacement
                            newDict[k] = repDict
                        } else {
                            newDict[k] = [newName: replacement]
                        }
                    }
                } else if let subdict = dict[k] as? [String: Any] {
                    newDict[k] = changeValue(dict: subdict, keyName: keyName, newName: newName, replacement: replacement, remove: remove)
                }
            }
            return newDict
        }
        
        var changed = list
        changed["materialSettingsVersion"] = nil
        changed["visualStyleSetVersion"] = nil
        changed["MdC"] = nil
        
        let tintColor: [String: Double] = [
            "alpha": color.alpha,
            "red": color.red,
            "green": color.green,
            "blue": color.blue
        ]
        let tinting: [String: Any] = [
            "tintAlpha": color.alpha,
            "tintColor": tintColor
        ]
        
        let newMaterialFiltering: [String: Any] = [
            "blurRadius": blur,
            "tinting": tinting
        ]
        
        changed = changeValue(dict: changed, keyName: "blurRadius", newName: "blurRadius", replacement: blur)
        changed = changeValue(dict: changed, keyName: "materialFiltering", newName: "materialFiltering", replacement: newMaterialFiltering)
        changed = changeValue(dict: changed, keyName: "filtering", newName: "tinting", replacement: tinting)
        
        // return it
        return changed
    }
}
