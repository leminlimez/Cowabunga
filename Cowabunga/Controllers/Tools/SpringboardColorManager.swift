//
//  SpringboardColorManager.swift
//  Cowabunga
//
//  Created by lemin on 2/1/23.
//

import SwiftUI

class SpringboardColorManager {
    enum SpringboardType {
        case dock
        case folder
    }
    
    static func applyColor(forType: SpringboardType, color: UIColor) {
        var modifyingFiles: [URL] = []
        let bgDir = getBackgroundDirectory()
        if bgDir != nil {
            // get the file
            if forType == SpringboardType.folder {
                modifyingFiles.append(Bundle.main.url(forResource: "folder", withExtension: "materialrecipe")!)
                modifyingFiles.append(Bundle.main.url(forResource: "folderExpandedBackgroundHome", withExtension: "materialrecipe")!)
            }
            
            // set the colors
            for (_, url) in modifyingFiles.enumerated() {
                do {
                    let plistData = try Data(contentsOf: url)
                    var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                    
                    if var firstLevel = plist["baseMaterial"] as? [String : Any], var secondLevel = firstLevel["tinting"] as? [String: Any], var thirdLevel = secondLevel["tintColor"] as? [String: Any] {
                        // set the colors
                        thirdLevel["red"] = color.rgba.red
                        thirdLevel["green"] = color.rgba.green
                        thirdLevel["blue"] = color.rgba.blue
                        thirdLevel["alpha"] = color.rgba.alpha
                        
                        secondLevel["tintColor"] = thirdLevel
                        firstLevel["tinting"] = secondLevel
                        plist["baseMaterial"] = firstLevel
                    }
                    
                    // write the new file
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            UIApplication.shared.alert(body: "Could not find the background files directory!")
        }
    }
    
    // get the directory of where background files are saved
    static func getBackgroundDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Background_Files")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the background files directory")
        }
        return nil
    }
}
