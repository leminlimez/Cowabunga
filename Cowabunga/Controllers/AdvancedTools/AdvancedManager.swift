//
//  AdvancedManager.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation

class AdvancedManager {
    static func getSavedOperationsDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Saved_Operations")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            createUnnamedFolder(folderURL: newURL)
            return newURL
        } catch {
            print("An error occurred getting/making the saved operations directory")
        }
        return nil
    }
    
    private static func createUnnamedFolder(folderURL: URL) {
        do {
            let unnamedURL = folderURL.appendingPathComponent("Unnamed")
            if !FileManager.default.fileExists(atPath: unnamedURL.path) {
                try FileManager.default.createDirectory(at: unnamedURL, withIntermediateDirectories: false)
            }
        } catch {
            print("An error occurred making unnamed directory")
        }
    }
    
    private static func getOperationProperty(_ info: [String: Any], key: String) throws -> Any {
        if info[key] == nil {
            throw "Property \(key) unexpectedly found as nil!"
        }
        return info[key]!
    }
    
    static func getOperationFromName(operationName: String) throws -> AdvancedObject {
        let savedPath = getSavedOperationsDirectory()
        if savedPath != nil {
            for cat in try FileManager.default.contentsOfDirectory(at: savedPath!, includingPropertiesForKeys: nil) {
                let operation = cat.appendingPathComponent(operationName)
                if FileManager.default.fileExists(atPath: operation.path) {
                    // create and return the object
                    let plistPath = operation.appendingPathComponent("Info.plist")
                    if !FileManager.default.fileExists(atPath: plistPath.path) {
                        throw "No info plist found!"
                    }
                    let plistData = try Data(contentsOf: plistPath)
                    let operationInfo = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                    
                    // get the basic global properties
                    let filePath: String = try getOperationProperty(operationInfo, key: "FilePath") as! String
                    let applyInBackground: Bool = try getOperationProperty(operationInfo, key: "ApplyInBackground") as! Bool
                    
                    // get the type
                    let operationType: String = try getOperationProperty(operationInfo, key: "OperationType") as! String
                    if operationType == "Corrupting" {
                        // create a corrupting type
                        return CorruptingObject.init(operationName: operationName, filePath: filePath, singleApply: false, applyInBackground: applyInBackground)
                    } else if operationType == "Replacing" {
                        let replacingType = try getOperationProperty(operationInfo, key: "ReplacingType") as! String
                    }
                    
                    throw "Could not get operation type!"
                }
            }
            throw "Operation save file not found!"
        } else {
            throw "No save path found!"
        }
    }
    
    static func saveOperation(operation: AdvancedObject, category: String) throws {
        let savedPath = getSavedOperationsDirectory()
        if savedPath != nil {
            let categoryPath = savedPath!.appendingPathComponent(category)
            if FileManager.default.fileExists(atPath: categoryPath.path) {
                let operationPath = categoryPath.appendingPathComponent(operation.operationName)
                if FileManager.default.fileExists(atPath: operationPath.path) {
                    // delete the file
                    do {
                        try FileManager.default.removeItem(at: operationPath)
                    } catch {
                        print("Could not delete operation folder: \(error.localizedDescription)")
                    }
                }
                // create the folder
                try FileManager.default.createDirectory(at: operationPath, withIntermediateDirectories: false)
                
                // create the plist
                var plist: [String: Any] = [
                    "FilePath": operation.filePath,
                    "ApplyInBackground": operation.applyInBackground
                ]
                
                // add the operation type
                if operation is CorruptingObject {
                    plist["OperationType"] = "Corrupting"
                } else if operation is ReplacingObject, let replacingOperation = operation as? ReplacingObject {
                    plist["OperationType"] = "Replacing"
                    // add the other replacing data
                    plist["ReplacingType"] = replacingOperation.replacingType.rawValue
                    plist["ReplacingPath"] = replacingOperation.replacingPath
                }
                
                // serialize and write the plist
                let plistData: Data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                try plistData.write(to: operationPath.appendingPathComponent("Info.plist"))
            } else {
                throw "The category path could not be found!"
            }
        } else {
            throw "No save path found!"
        }
    }
}
