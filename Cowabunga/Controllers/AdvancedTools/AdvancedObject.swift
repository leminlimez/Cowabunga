//
//  AdvancedObject.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation
import MacDirtyCowSwift
import SwiftUI
import AssetCatalogWrapper

enum ReplacingObjectType: String, CaseIterable {
    case FilePath = "File Path"
    case Imported = "Imported"
}

class AdvancedCategory: Identifiable {
    var id = UUID()
    var name: String
    var isActive: Bool
    var operations: [AdvancedCategory]?
    var categoryName: String?
    var author: String
    
    init(name: String, author: String = "", isActive: Bool = true, operations: [AdvancedCategory]? = nil, categoryName: String? = nil) {
        self.name = name
        self.isActive = isActive
        self.operations = operations
        self.categoryName = categoryName
        self.author = author
    }
}

class AdvancedObject: Identifiable {
    var id = UUID()
    
    var operationName: String
    var filePath: String
    var replacementData: Data? = nil
    var backupData: Data? = nil
    var applyInBackground: Bool
    var isCreating: Bool = false
    var isActive: Bool = true
    var author: String
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, creating: Bool = false, active: Bool = true) {
        self.operationName = operationName
        self.filePath = filePath
        self.applyInBackground = applyInBackground
        self.backupData = backupData
        self.isCreating = creating
        self.isActive = active
        self.author = author
    }
    
    func backup() throws {
        // back up the data at the file path
        if !isCreating {
            backupData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        }
    }
    
    func parseData() throws {
        // parse the data to be replaced
    }
    
    func applyData(fromBackup: Bool = false) throws {
        var newData: Data? = nil
        if fromBackup && !isCreating {
            newData = backupData
        } else {
            newData = replacementData
        }
        // applies the data only if it was parsed
        if newData != nil {
            if FileManager.default.fileExists(atPath: filePath) {
                // get data of and make sure it is smaller
                // first try to write normally
                do {
                    try newData!.write(to: URL(fileURLWithPath: filePath))
                } catch {
                    // if it fails, revert back to MDC
                    print("classic write failed... reverting back to MacDirtyCow")
                    do {
                        let originalSize = try Data(contentsOf: URL(fileURLWithPath: filePath)).count
                        if originalSize >= newData!.count {
                            try MDC.overwriteFile(at: filePath, with: newData!)
                        } else {
                            throw "Replacement data is larger than the original file!"
                        }
                    } catch {
                        throw error.localizedDescription
                    }
                }
            } else if isCreating {
                try newData!.write(to: URL(fileURLWithPath: filePath))
            } else {
                throw "No file exists at path!"
            }
        } else {
            if fromBackup {
                throw "No backup data was found!"
            } else {
                throw "Data not parsed before applying!"
            }
        }
    }
}

class NullObject: AdvancedObject {
    init() {
        super.init(operationName: "Null", filePath: "/", applyInBackground: false)
    }
}

class CorruptingObject: AdvancedObject {
    override func parseData() throws {
        // create empty data
        self.replacementData = Data("###".utf8)
    }
}

class ReplacingObject: AdvancedObject {
    var replacingType: ReplacingObjectType
    var replacingPath: String
    
    override func parseData() throws {
        // get the data from the files
        if FileManager.default.fileExists(atPath: self.replacingPath) {
            self.replacementData = try Data(contentsOf: URL(fileURLWithPath: self.replacingPath))
        } else {
            throw "No file exists at path \(self.replacingPath)!"
        }
    }
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, creating: Bool = false, active: Bool = true, overwriteData: Data, replacingType: ReplacingObjectType, replacingPath: String) {
        self.replacingType = replacingType
        self.replacingPath = replacingPath
        super.init(operationName: operationName, author: author, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, creating: creating, active: active)
        self.replacementData = overwriteData
    }
}

class PlistObject: AdvancedObject {
    var plistType: PropertyListSerialization.PropertyListFormat
    var replacingKeys: [String: Any] = [:]
    
    override func parseData() throws {
        // get the original plist file
        let plistData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        var newPlist = plist
        for (k, v) in replacingKeys {
            if (v is String && (v as! String) == ".Cowabunga-DELETIGN") {
                newPlist = AdvancedManager.deleteDictValue(newPlist, k)
            } else {
                newPlist = AdvancedManager.changeDictValue(newPlist, k, v)
            }
        }
        // add empty data if binary
        if plistType == PropertyListSerialization.PropertyListFormat.binary {
            replacementData = try addEmptyData(matchingSize: plistData.count, to: newPlist)
        } else {
            replacementData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: plistType, options: 0)
        }
    }
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, active: Bool = true, plistType: PropertyListSerialization.PropertyListFormat, replacingKeys: [String: Any] = [:]) {
        self.plistType = plistType
        self.replacingKeys = replacingKeys
        super.init(operationName: operationName, author: author, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: active)
    }
}

class ColorObject: AdvancedObject {
    var col: Color
    var blur: Double
    
    override func parseData() throws {
        // get the files
        let url = Bundle.main.url(forResource: "replacement", withExtension: ".materialrecipe")
        let color: CIColor = CIColor(color: UIColor(col))
        
        // set the colors
        if url != nil {
            self.replacementData = try ColorSwapManager.setColor(url: url!, color: color, blur: Int(blur))
        } else {
            throw "Could not find original resource url"
        }
    }
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, active: Bool = true, color: Color = Color.gray, blur: Double = 30) {
        self.col = color
        self.blur = blur
        super.init(operationName: operationName, author: author, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: active)
    }
}

class AssetCatalogObject: AdvancedObject {
    var replacingImages: [String: UIImage]
    var cachedRenditions: [Rendition] = []
    var cachedViewingImages: [String: UIImage] = [:]
    
    func getRenditions() -> [Rendition] {
        if FileManager.default.fileExists(atPath: filePath) && cachedRenditions.count == 0 {
            cachedRenditions = AssetCatalogManager.getAssetRenditions(URL(fileURLWithPath: filePath))
        }
        return cachedRenditions
    }
    
    func getAssets() -> [String: UIImage] {
        if cachedViewingImages.count == 0 {
            let renditions = getRenditions()
            for rendition in renditions {
                if rendition.image != nil {
                    cachedViewingImages[rendition.name] = UIImage(cgImage: rendition.image!)
                }
            }
        }
        return cachedViewingImages
    }
    
    func resetRenditions() {
        cachedRenditions.removeAll()
        cachedViewingImages.removeAll()
    }
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, active: Bool = true, replacingImages: [String: UIImage] = [:]) {
        self.replacingImages = replacingImages
        super.init(operationName: operationName, author: author, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: active)
    }
}
