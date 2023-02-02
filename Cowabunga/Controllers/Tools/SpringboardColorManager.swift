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
    
    private static let finalFiles: [SpringboardType: [String]] = [
        SpringboardType.folder: ["folderDark", "folderLight"],
        SpringboardType.dock: ["dockDark", "dockLight"]
    ]
    
    private static let fileFolders: [SpringboardType: String] = [
        SpringboardType.folder: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/",
        SpringboardType.dock: "/System/Library/PrivateFrameworks/CoreMaterial.framework/"
    ]
    
    static func createColor(forType: SpringboardType, color: UIColor) throws {
        let bgDir = getBackgroundDirectory()
        
        if bgDir != nil && finalFiles[forType] != nil && fileFolders[forType] != nil {
            // get the files
            let url = Bundle.main.url(forResource: "replacement", withExtension: ".materialrecipe")
            
            // set the colors
            if url != nil {
                do {
                    let plistData = try Data(contentsOf: url!)
                    var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                    
                    if var firstLevel = plist["baseMaterial"] as? [String : Any], var secondLevel = firstLevel["tinting"] as? [String: Any], var thirdLevel = secondLevel["tintColor"] as? [String: Any] {
                        // set the colors
                        thirdLevel["red"] = color.rgba.red
                        thirdLevel["green"] = color.rgba.green
                        thirdLevel["blue"] = color.rgba.blue
                        thirdLevel["alpha"] = 1
                        
                        secondLevel["tintColor"] = thirdLevel
                        secondLevel["tintAlpha"] = color.rgba.alpha
                        firstLevel["tinting"] = secondLevel
                        plist["baseMaterial"] = firstLevel
                    }
                    
                    // fill with empty data
                    for (_, file) in finalFiles[forType]!.enumerated() {
                        // get original data
                        let path: String = "\(fileFolders[forType]!)\(file).materialrecipe"
                        let newUrl = URL(fileURLWithPath: path)
                        do {
                            let originalFileSize = try Data(contentsOf: newUrl).count
                            let newData = try addEmptyData(matchingSize: originalFileSize, to: plist)
                            // save file to background directory
                            if newData.count == originalFileSize {
                                try newData.write(to: bgDir!.appendingPathComponent(file+".materialrecipe"))
                            } else {
                                print("NOT CORRECT SIZE")
                            }
                        } catch {
                            print(error.localizedDescription)
                            throw error.localizedDescription
                        }
                    }
                }
            } else {
                throw "Could not find original resource url"
            }
        } else {
            throw "Could not find the background files directory!"
        }
    }
    
    static func applyColor(forType: SpringboardType) {
        let bgDir = getBackgroundDirectory()
        
        if bgDir != nil && finalFiles[forType] != nil && fileFolders[forType] != nil {
            for (_, file) in finalFiles[forType]!.enumerated() {
                do {
                    let newData = try Data(contentsOf: bgDir!.appendingPathComponent(file + ".materialrecipe"))
                    // overwrite file
                    let path: String = "\(fileFolders[forType]!)\(file).materialrecipe"
                    let _ = overwriteFileWithDataImpl(originPath: path, replacementData: newData)
                } catch {
                    print(error.localizedDescription)
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
