//
//  AdvancedManager.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation
import ZIPFoundation
import SwiftUI

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
    
    static func deleteDictValue(_ dict: [String: Any], _ key: String) -> [String: Any] {
        var newDict = dict
        for (k, v) in dict {
            if k == key {
                newDict[k] = nil
            } else if let subDict = v as? [String: Any] {
                newDict[k] = deleteDictValue(subDict, key)
            }
        }
        return newDict
    }
    
    // MARK: Export Operation
    static func exportOperation(_ operationName: String) throws -> URL {
        let fm = FileManager.default
        let operationURL: URL = try getOperationURLFromName(operationName)
        var archiveURL: URL?
        var error: NSError?
        let coordinator = NSFileCoordinator()
        
        coordinator.coordinate(readingItemAt: operationURL, options: [.forUploading], error: &error) { (zipURL) in
            let tmpURL = try! fm.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: zipURL,
                create: true
            ).appendingPathComponent("\(operationName).cowperation")
            try! fm.moveItem(at: zipURL, to: tmpURL)
            archiveURL = tmpURL
        }
        
        if let archiveURL = archiveURL {
            return archiveURL
        } else {
            throw "There was an error exporting"
        }
    }
    
    // MARK: Import Operation
    static func importOperation(_ url: URL) throws -> Bool {
        let fm = FileManager.default
        var editsVar: Bool = false
        
        if url.pathExtension == "cowperation" {
            let unzipURL = fm.temporaryDirectory.appendingPathComponent("cowperation_unzip")
            try? fm.removeItem(at: unzipURL)
            try fm.unzipItem(at: url, to: unzipURL)
            let savePath = getSavedOperationsDirectory()!.appendingPathComponent("None")
            for folder in (try? fm.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: nil)) ?? [] {
                do {
                    let plistURL = folder.appendingPathComponent("Info.plist")
                    let plistData = try Data(contentsOf: plistURL)
                    let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                    if (plist["FilePath"] as! String).starts(with: "/var") {
                        editsVar = true
                    }
                }
                // disable the operation by default
                if !fm.fileExists(atPath: folder.appendingPathComponent(".disabled").path) {
                    try Data("#".utf8).write(to: folder.appendingPathComponent(".disabled"))
                }
                try fm.moveItem(at: folder, to: savePath.appendingPathComponent(getAvailableName(folder.deletingPathExtension().lastPathComponent)))
            }
        } else if url.pathExtension == "fsp" {
            editsVar = try FSPConverter.convertFromFSP(url)
        } else {
            throw "No .cowperation file found!"
        }
        return editsVar
    }
    
    static func getAvailableName(_ operationName: String) -> String {
        let savedPath: URL = getSavedOperationsDirectory()!.appendingPathComponent("None")
        var currentName: String = operationName
        var currentNum: Int = 0
        while FileManager.default.fileExists(atPath: savedPath.appendingPathComponent(currentName).path) {
            currentNum += 1
            currentName = operationName + " \(currentNum)"
        }
        return currentName
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
        } else if operationType == "Replacing" || operationType == "Creating" {
            let replacingType = try getOperationProperty(operationInfo, key: "ReplacingType") as! String
            var replacingTypeObject: ReplacingObjectType? = nil
            var replacingPath = try getOperationProperty(operationInfo, key: "ReplacingPath") as! String
            if replacingType == ReplacingObjectType.Imported.rawValue {
                replacingTypeObject = ReplacingObjectType.Imported
                replacingPath = operationURL.appendingPathComponent(replacingPath).path
            } else if replacingType == ReplacingObjectType.FilePath.rawValue {
                replacingTypeObject = ReplacingObjectType.FilePath
            }
            
            let isCreating: Bool = (operationType == "Creating")
            
            if replacingTypeObject == nil {
                throw "Could not get replacing object type!"
            }
            var replacingData: Data? = nil
            do {
                replacingData = try Data(contentsOf: URL(fileURLWithPath: replacingPath))
            } catch {
                print(error.localizedDescription)
            }
            return ReplacingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, creating: isCreating, active: isActive, overwriteData: replacingData ?? Data("#".utf8), replacingType: replacingTypeObject!, replacingPath: replacingPath)
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
        } else if operationType == "Color" {
            let r = try getOperationProperty(operationInfo, key: "red") as? Double ?? CIColor.gray.red
            let g = try getOperationProperty(operationInfo, key: "green") as? Double ?? CIColor.gray.green
            let b = try getOperationProperty(operationInfo, key: "blue") as? Double ?? CIColor.gray.blue
            let a = try getOperationProperty(operationInfo, key: "alpha") as? Double ?? 1
            let blur = try getOperationProperty(operationInfo, key: "blur") as? Double ?? 30
            
            let color = Color.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b)).opacity(a)
            
            let usesStyles = try getOperationProperty(operationInfo, key: "UsesStyles")
            if usesStyles as? Bool == true {
                let fill = try getOperationProperty(operationInfo, key: "fill") as? String ?? ""
                let stroke = try getOperationProperty(operationInfo, key: "stroke") as? String ?? ""
                return ColorObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, active: isActive, color: color, blur: blur, usesStyles: true, fill, stroke)
            } else {
                return ColorObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, active: isActive, color: color, blur: blur)
            }
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
    
    static func getOperationFromName_SAFE(operationName: String) -> AdvancedObject {
        do {
            return try getOperationFromName(operationName: operationName)
        } catch {
            return CorruptingObject(operationName: operationName, filePath: "Unknown", applyInBackground: false)
        }
    }
    
    static func getOperationURLFromName(_ operationName: String) throws -> URL {
        let savedPath = getSavedOperationsDirectory()
        if savedPath != nil {
            for cat in try FileManager.default.contentsOfDirectory(at: savedPath!, includingPropertiesForKeys: nil) {
                let operation = cat.appendingPathComponent(operationName)
                if FileManager.default.fileExists(atPath: operation.path) {
                    return operation
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
                    var author: String = ""
                    do {
                        let plistData = try Data(contentsOf: operation.appendingPathComponent("Info.plist"))
                        let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                        author = (plist["Author"] as? String) ?? ""
                    } catch {
                        print(error.localizedDescription)
                    }
                    categoryOperations.append(.init(name: operation.lastPathComponent, author: author, isActive: isActive, categoryName: categoryName))
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
        
        // add the author if there is one
        if operation.author != "" {
            plist["Author"] = operation.author
        }
        
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
            if replacingOperation.isCreating {
                plist["OperationType"] = "Creating"
            } else {
                plist["OperationType"] = "Replacing"
            }
            // add the other replacing data
            plist["ReplacingType"] = replacingOperation.replacingType.rawValue
            if replacingOperation.replacingType == ReplacingObjectType.Imported {
                // remove the app path from the info
                let repFileName = URL(fileURLWithPath: replacingOperation.replacingPath).lastPathComponent
                try operation.replacementData?.write(to: operationPath.appendingPathComponent(repFileName))
                plist["ReplacingPath"] = repFileName
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
        } else if operation is ColorObject, let colorOperation = operation as? ColorObject {
            plist["OperationType"] = "Color"
            // set the color
            let color: CIColor = CIColor(color: UIColor(colorOperation.col))
            plist["red"] = Double(color.red)
            plist["green"] = Double(color.green)
            plist["blue"] = Double(color.blue)
            plist["alpha"] = Double(color.alpha)
            plist["blur"] = colorOperation.blur
            
            plist["UsesStyles"] = colorOperation.usesStyles
            if colorOperation.usesStyles {
                plist["fill"] = colorOperation.fill
                plist["stroke"] = colorOperation.stroke
            }
        }
        
        // serialize and write the plist
        let plistData: Data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try plistData.write(to: operationPath.appendingPathComponent("Info.plist"))
    }
}
