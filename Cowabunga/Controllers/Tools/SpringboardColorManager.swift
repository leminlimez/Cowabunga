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
    
    static func createColor(forType: SpringboardType, color: UIColor) throws {
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
                    
                    // fill with empty data
                    var files: [String] = []
                    if url.deletingPathExtension().lastPathComponent == "folder" {
                        files.append("folderDark")
                        files.append("folderLight")
                    } else if url.deletingPathExtension().lastPathComponent == "folderExpandedBackgroundHome" {
                        files.append("folderExpandedBackgroundHome")
                    }
                    for (_, file) in files.enumerated() {
                        // get original data
                        let path: String = "/System/Library/PrivateFrameworks/SpringBoardHome.framework/\(file).materialrecipe"
                        print(path)
                        let newUrl = URL(string: path)
                        do {
                            let originalFileSize = try Data(contentsOf: newUrl!).count
                            let newData = try fillEmptyData(originalSize: originalFileSize, plist: plist)
                            // save file to background directory
                            if newData.count == originalFileSize {
                                try newData.write(to: bgDir!.appendingPathComponent(file+".materialrecipe"))
                            } else {
                                print("NOT CORRECT SIZE")
                                throw "ER"
                            }
                        } catch {
                            print(error.localizedDescription)
                            throw "ET"
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    print("ORIGINAL")
                    throw "ER"
                }
            }
        } else {
            throw "Could not find the background files directory!"
        }
    }
    
    static func applyColor(forType: SpringboardType) {
        let bgDir = getBackgroundDirectory()
        
        if bgDir != nil {
            if forType == SpringboardType.folder {
                let files = ["folderDark", "folderLight", "folderExpandedBackgroundHome"]
                for (_, file) in files.enumerated() {
                    do {
                        let newData = try Data(contentsOf: bgDir!.appendingPathComponent(file + ".materialrecipe"))
                        // overwrite file
                        let path: String = "/System/Library/PrivateFrameworks/SpringBoardHome.framework/\(file).materialrecipe"
                        let _ = overwriteFileWithDataImpl(originPath: path, replacementData: newData)
                    } catch {
                        print(error.localizedDescription)
                        print("SECOND")
                    }
                }
            }
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
