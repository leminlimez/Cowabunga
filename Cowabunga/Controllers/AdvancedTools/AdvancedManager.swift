//
//  AdvancedManager.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation

class AdvancedManager {
    static func changeDictValue(_ dict: [String: Any], _ key: String, _ value: Any) -> [String: Any] {
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
    
    static func deleteOperation(operationName: String) throws {
        let savedPath = getSavedOperationsDirectory()
        if savedPath != nil {
            for cat in try FileManager.default.contentsOfDirectory(at: savedPath!, includingPropertiesForKeys: nil) {
                let operation = cat.appendingPathComponent(operationName)
                if FileManager.default.fileExists(atPath: operation.path) {
                    try FileManager.default.removeItem(at: operation)
                    return
                }
            }
        } else {
            throw "No save path found!"
        }
    }
    
    private static func createUnnamedFolder(folderURL: URL) {
        do {
            if !FileManager.default.fileExists(atPath: folderURL.appendingPathComponent("None").path) {
                try createCategory(folderURL: folderURL, categoryName: "None")
            }
        } catch {
            print("An error occurred making unnamed directory")
        }
    }
    
    public static func createCategory(folderURL: URL, categoryName: String) throws {
        let catURL = folderURL.appendingPathComponent(categoryName)
        if !FileManager.default.fileExists(atPath: catURL.path) {
            try FileManager.default.createDirectory(at: catURL, withIntermediateDirectories: false)
        } else {
            throw "Category of this name already exists!"
        }
    }
    
    private static func getOperationProperty(_ info: [String: Any], key: String) throws -> Any {
        if info[key] == nil {
            throw "Property \(key) unexpectedly found as nil!"
        }
        return info[key]!
    }
    
    static func createOperationFromURL(operationURL: URL) throws -> AdvancedObject {
        // create and return the object
        let operationName: String = operationURL.lastPathComponent
        let plistPath = operationURL.appendingPathComponent("Info.plist")
        if !FileManager.default.fileExists(atPath: plistPath.path) {
            throw "No info plist found!"
        }
        let plistData = try Data(contentsOf: plistPath)
        let operationInfo = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        
        let isActive: Bool = !FileManager.default.fileExists(atPath: operationURL.appendingPathComponent(".disabled").path)
        
        // get the basic global properties
        let filePath: String = try getOperationProperty(operationInfo, key: "FilePath") as! String
        let applyInBackground: Bool = try getOperationProperty(operationInfo, key: "ApplyInBackground") as! Bool
        
        // get the backup data
        var backupData: Data? = nil
        if FileManager.default.fileExists(atPath: operationURL.appendingPathComponent(".backup").path) {
            do {
                backupData = try Data(contentsOf: operationURL.appendingPathComponent(".backup"))
            } catch {
                print("BACKUP DATA FETCHING ERROR: \(error.localizedDescription)")
            }
        }
        
        // get the type
        let operationType: String = try getOperationProperty(operationInfo, key: "OperationType") as! String
        if operationType == "Corrupting" {
            // create a corrupting type
            return CorruptingObject.init(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: isActive)
        } else if operationType == "Replacing" {
            let replacingType = try getOperationProperty(operationInfo, key: "ReplacingType") as! String
            var replacingTypeObject: ReplacingObjectType? = nil
            var replacingPath = try getOperationProperty(operationInfo, key: "ReplacingPath") as! String
            if replacingType == ReplacingObjectType.Imported.rawValue {
                replacingTypeObject = ReplacingObjectType.Imported
                replacingPath = operationURL.appendingPathComponent(replacingPath).path
            } else if replacingType == ReplacingObjectType.FilePath.rawValue {
                replacingTypeObject = ReplacingObjectType.FilePath
            }
            
            if replacingTypeObject == nil {
                throw "Could not get replacing object type!"
            }
            let replacingData: Data = try Data(contentsOf: URL(fileURLWithPath: replacingPath))
            return ReplacingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: isActive, overwriteData: replacingData, replacingType: replacingTypeObject!, replacingPath: replacingPath)
        } else if operationType == "Plist" {
            let plistTypeString = try getOperationProperty(operationInfo, key: "PlistType") as! String
            var plistType: PropertyListSerialization.PropertyListFormat
            if plistTypeString == "xml" {
                plistType = PropertyListSerialization.PropertyListFormat.xml
            } else {
                plistType = PropertyListSerialization.PropertyListFormat.binary
            }
            let plistData = try Data(contentsOf: operationURL.appendingPathComponent("SavedValues.plist"))
            let replacementKeys = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
            return PlistObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: isActive, plistType: plistType, replacingKeys: replacementKeys)
        }
        
        throw "Could not get operation type!"
    }
    
    static func getOperationFromName(operationName: String) throws -> AdvancedObject {
        let savedPath = getSavedOperationsDirectory()
        if savedPath != nil {
            for cat in try FileManager.default.contentsOfDirectory(at: savedPath!, includingPropertiesForKeys: nil) {
                let operation = cat.appendingPathComponent(operationName)
                if FileManager.default.fileExists(atPath: operation.path) {
                    return try createOperationFromURL(operationURL: operation)
                }
            }
            throw "Operation save file not found!"
        } else {
            throw "No save path found!"
        }
    }
    
    static func loadOperations() throws -> [AdvancedCategory] {
        let savedPath = getSavedOperationsDirectory()
        if savedPath == nil {
            throw "No save path found!"
        }
        var operations: [AdvancedCategory] = []
        for cat in try FileManager.default.contentsOfDirectory(at: savedPath!, includingPropertiesForKeys: nil) {
            do {
                let categoryName = cat.lastPathComponent
                var categoryOperations: [AdvancedCategory] = []
                for operation in try FileManager.default.contentsOfDirectory(at: cat, includingPropertiesForKeys: nil) {
                    var isActive = true
                    if FileManager.default.fileExists(atPath: operation.appendingPathComponent(".disabled").path) {
                        isActive = false
                    }
                    categoryOperations.append(.init(name: operation.lastPathComponent, isActive: isActive, categoryName: categoryName))
                }
                operations.append(.init(name: categoryName, operations: categoryOperations))
            } catch {
                print(error.localizedDescription)
            }
        }
        return operations
    }
    
    static func applyOperations(background: Bool) throws {
        let savedPath = getSavedOperationsDirectory()
        if savedPath == nil {
            throw "No save path found!"
        }
        for cat in try FileManager.default.contentsOfDirectory(at: savedPath!, includingPropertiesForKeys: nil) {
            do {
                for operation in try FileManager.default.contentsOfDirectory(at: cat, includingPropertiesForKeys: nil) {
                    do {
                        if !FileManager.default.fileExists(atPath: operation.appendingPathComponent(".disabled").path) {
                            let operationObj = try createOperationFromURL(operationURL: operation)
                            if background == false || operationObj.applyInBackground == true {
                                // parse the data
                                try operationObj.parseData()
                                // apply
                                try operationObj.applyData()
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func getOperationFolder(operationName: String, category: String) throws -> URL {
        let savedPath = getSavedOperationsDirectory()
        if savedPath == nil {
            throw" No save path found!"
        }
        let categoryPath = savedPath!.appendingPathComponent(category)
        if !FileManager.default.fileExists(atPath: categoryPath.path) {
            throw "The category path could not be found!"
        }
        let operationPath = categoryPath.appendingPathComponent(operationName)
        if !FileManager.default.fileExists(atPath: operationPath.path) {
            // create the folder
            try FileManager.default.createDirectory(at: operationPath, withIntermediateDirectories: false)
        }
        return operationPath
    }
    
    static func saveOperation(operation: AdvancedObject, category: String, replacingFileData: Data? = nil) throws {
        let operationPath = try getOperationFolder(operationName: operation.operationName, category: category)
        if !FileManager.default.fileExists(atPath: operationPath.path) {
            // create the folder
            try FileManager.default.createDirectory(at: operationPath, withIntermediateDirectories: false)
        }
        
        // create the plist
        var plist: [String: Any] = [
            "FilePath": operation.filePath,
            "ApplyInBackground": operation.applyInBackground
        ]
        
        // create the backup data
        if operation.backupData != nil {
            try operation.backupData!.write(to: operationPath.appendingPathComponent(".backup"))
        }
        
        if !operation.isActive {
            try Data("#".utf8).write(to: operationPath.appendingPathComponent(".disabled"))
        }
        
        // add the operation type
        if operation is CorruptingObject {
            plist["OperationType"] = "Corrupting"
        } else if operation is ReplacingObject, let replacingOperation = operation as? ReplacingObject {
            plist["OperationType"] = "Replacing"
            // add the other replacing data
            plist["ReplacingType"] = replacingOperation.replacingType.rawValue
            if replacingOperation.replacingType == ReplacingObjectType.Imported {
                // remove the app path from the info
                try replacingOperation.replacementData!.write(to: operationPath.appendingPathComponent(".rawData"))
                plist["ReplacingPath"] = operationPath.appendingPathComponent(".rawData").path
            } else {
                plist["ReplacingPath"] = replacingOperation.replacingPath
            }
        } else if operation is PlistObject, let plistOperation = operation as? PlistObject {
            plist["OperationType"] = "Plist"
            // set the plist type
            if plistOperation.plistType == PropertyListSerialization.PropertyListFormat.xml {
                plist["PlistType"] = "xml"
            } else {
                plist["PlistType"] = "binary"
            }
            // save the plist file
            let plistData = try PropertyListSerialization.data(fromPropertyList: plistOperation.replacingKeys, format: plistOperation.plistType, options: 0)
            try plistData.write(to: operationPath.appendingPathComponent("SavedValues.plist"))
        }
        
        // serialize and write the plist
        let plistData: Data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try plistData.write(to: operationPath.appendingPathComponent("Info.plist"))
    }
}
