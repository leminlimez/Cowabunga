//
//  FSPConverter.swift
//  Cowabunga
//
//  Created by lemin on 2/27/23.
//

import Foundation
import Zip
import SwiftUI

class FSPConverter {
    private static func getOperationType(_ Mode: Int) -> String {
        if Mode == 1 {
            return "Replacing"
        } else if Mode == 2 {
            return "Creating"
        } else if Mode == 3 {
            return "Color"
        } else {
            return "Corrupting"
        }
    }
    
    private static func getFSPOperations(_ info: [String: Any]) throws -> [[String: Any]] {
        var returning: [[String: Any]] = []
        if info["IsFolder"] as? Bool == true {
            if let children: [[String: Any]] = info["Child"] as? [[String: Any]] {
                for child in children {
                    try? returning.append(contentsOf: getFSPOperations(child))
                }
                return returning
            } else {
                throw "Error getting children!"
            }
        } else {
            var newOperation: [String: Any] = [:]
            newOperation["Name"] = AdvancedManager.getAvailableName(info["Name"] as? String ?? "Unnamed")
            newOperation["FilePath"] = info["TargetFilePath"] as? String ?? "Unknown"
            newOperation["Author"] = info["Share_Author"] as? String ?? ""
            newOperation["Active"] = info["Selected"] as? Bool ?? false
            newOperation["ApplyInBackground"] = info["LocationRequire"] as? Bool ?? false
            newOperation["OperationType"] = getOperationType(info["Mode"] as? Int ?? 0)
            newOperation["ID"] = info["ID"] as? String ?? ""
            
            if newOperation["OperationType"] as! String == "Color" {
                newOperation["Blur"] = info["Blur"] as? Double ?? 30
                newOperation["HexColor"] = info["hexColor"] ?? "#EBEBEB17"
            } else if newOperation["OperationType"] as! String == "Replacing" || newOperation["OperationType"] as! String == "Creating" {
                if info["OverwriteFilePath_Path"] as? String ?? "" == "" {
                    newOperation["ReplacingPath"] = info["OverwriteFile_Name"] as? String ?? "Unknown"
                    newOperation["ReplacingType"] = "Imported"
                } else {
                    newOperation["ReplacingPath"] = info["OverwriteFilePath_Path"] as? String ?? "Unknown"
                    newOperation["ReplacingType"] = "FilePath"
                }
            }
            
            returning.append(newOperation)
            return returning
        }
    }
    
    // Convert .fsp for importing
    static func convertFromFSP(_ url: URL) throws -> Bool {
        let fm = FileManager.default
        var editsVar: Bool = false
        
        // MARK: UNZIP
        let zipURL = fm.temporaryDirectory.appendingPathComponent(url.deletingPathExtension().appendingPathExtension("zip").lastPathComponent)
        if fm.fileExists(atPath: zipURL.path) {
            try? fm.removeItem(at: zipURL)
        }
        try fm.copyItem(at: url, to: zipURL)
        let outURL = fm.temporaryDirectory.appendingPathComponent("out")
        try Zip.unzipFile(zipURL, destination: outURL, overwrite: true, password: "aVBob25l5oyB44Gj44Gm6LuK5Lit5rOK44Gu5peF44Gr6KGM44GN44Gf44GE44Gq44CC44GC44Gj44Gf44GL44GE44Gf44G+44GU44KC6aOf44G544Gf44GE44GX44CC")
        try? fm.removeItem(at: zipURL)
        
        // MARK: CONVERT
        let cowURL = fm.temporaryDirectory.appendingPathComponent("cow")
        if fm.fileExists(atPath: cowURL.path) {
            try? fm.removeItem(at: cowURL)
        }
        
        // basic properties
        let infoJson = outURL.appendingPathComponent("Share/info.json")
        do {
            let info = try JSONSerialization.jsonObject(with: Data(contentsOf: infoJson)) as! [String: Any]
            
            let operations = try getFSPOperations(info)
            for operation in operations {
                // create the operation
                let opType: String = operation["OperationType"] as! String
                var opObj: AdvancedObject? = nil
                
                var backupData: Data? = nil
                var replaceData: Data = Data("#".utf8)
                if operation["ID"] as! String != "" {
                    let filesURL = outURL.appendingPathComponent("Share/Files/\(operation["ID"] as! String)")
                    if fm.fileExists(atPath: filesURL.appendingPathComponent("Default").path) {
                        backupData = try? Data(contentsOf: filesURL.appendingPathComponent("Default"))
                    }
                    if fm.fileExists(atPath: filesURL.appendingPathComponent("Replace").path) {
                        do {
                            replaceData = try Data(contentsOf: filesURL.appendingPathComponent("Replace"))
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
                let isActive: Bool = false // operation["Active"] as! Bool
                
                // check if it edits /var
                if (operation["FilePath"] as! String).starts(with: "/var") {
                    editsVar = true
                }
                
                if opType == "Corrupting" {
                    opObj = CorruptingObject.init(operationName: operation["Name"] as! String, author: operation["Author"] as! String, filePath: operation["FilePath"] as! String, applyInBackground: operation["ApplyInBackground"] as! Bool, backupData: backupData, active: isActive)
                } else if opType == "Replacing" {
                    opObj = ReplacingObject.init(operationName: operation["Name"] as! String, author: operation["Author"] as! String, filePath: operation["FilePath"] as! String, applyInBackground: operation["ApplyInBackground"] as! Bool, backupData: backupData, active: isActive, overwriteData: replaceData, replacingType: (operation["ReplacingType"] as! String == "FilePath" ? ReplacingObjectType.FilePath : ReplacingObjectType.Imported), replacingPath: operation["ReplacingPath"] as! String)
                } else if opType == "Creating" {
                    opObj = ReplacingObject.init(operationName: operation["Name"] as! String, author: operation["Author"] as! String, filePath: operation["FilePath"] as! String, applyInBackground: operation["ApplyInBackground"] as! Bool, backupData: backupData, creating: true, active: isActive, overwriteData: replaceData, replacingType: (operation["ReplacingType"] as! String == "FilePath" ? ReplacingObjectType.FilePath : ReplacingObjectType.Imported), replacingPath: operation["ReplacingPath"] as! String)
                } else if opType == "Color" {
                    opObj = ColorObject.init(operationName: operation["Name"] as! String, author: operation["Author"] as! String, filePath: operation["FilePath"] as! String, applyInBackground: operation["ApplyInBackground"] as! Bool, backupData: backupData, active: isActive, color: Color.init(hex: operation["HexColor"] as! String)!, blur: operation["Blur"] as! Double)
                    // determine the styles
                    if let opObj = opObj as? ColorObject {
                        var styles: [String: String] = [:]
                        do {
                            styles = try opObj.detectStyles()
                            if styles["fill"] != nil || styles["stroke"] != nil {
                                opObj.usesStyles = true
                                opObj.fill = styles["fill"] ?? ""
                                opObj.stroke = styles["stroke"] ?? ""
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
                if opObj != nil {
                    try? AdvancedManager.saveOperation(operation: opObj!, category: "None", replacingFileData: replaceData)
                }
            }
        } catch {
            try? fm.removeItem(at: outURL)
            try? fm.removeItem(at: cowURL)
            throw error.localizedDescription
        }
        return editsVar
    }
}
