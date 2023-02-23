//
//  AdvancedObject.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation
import MacDirtyCowSwift
import SwiftUI

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
    var isActive: Bool = true
    var author: String
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, active: Bool = true) {
        self.operationName = operationName
        self.filePath = filePath
        self.applyInBackground = applyInBackground
        self.backupData = backupData
        self.isActive = active
        self.author = author
    }
    
    func backup() throws {
        // back up the data at the file path
        backupData = try Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    func parseData() throws {
        // parse the data to be replaced
    }
    
    func applyData(fromBackup: Bool = false) throws {
        var newData: Data? = nil
        if fromBackup {
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
                            let succeeded = MDC.overwriteFile(at: filePath, with: newData!)
                            if !succeeded {
                                throw "There was an error trying to write/replace the file."
                            }
                        } else {
                            throw "Replacement data is larger than the original file!"
                        }
                    } catch {
                        throw error.localizedDescription
                    }
                }
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
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, active: Bool = true, overwriteData: Data, replacingType: ReplacingObjectType, replacingPath: String) {
        self.replacingType = replacingType
        self.replacingPath = replacingPath
        super.init(operationName: operationName, author: author, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: active)
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
    var usesStyles: Bool
    var fill: String
    var stroke: String
    
    func detectStyles() throws -> [String: String] {
        if FileManager.default.fileExists(atPath: self.filePath) {
            do {
                // get the data
                let originalData: Data = try Data(contentsOf: URL(fileURLWithPath: self.filePath))
                do {
                    // get the plist data
                    let plist = try PropertyListSerialization.propertyList(from: originalData, options: [], format: nil) as! [String: Any]
                    
                    // get the styles plist
                    if let stylesValues = plist["styles"] as? [String: String] {
                        var styles: [String: String] = [:]
                        styles["fill"] = stylesValues["fill"] ?? ""
                        styles["stroke"] = stylesValues["stroke"] ?? ""
                        return styles
                    } else {
                        return [:]
                    }
                } catch {
                    throw "Could not serialize file at path \(self.filePath)!"
                }
            } catch {
                throw "Could not get data of file at path \(self.filePath)!"
            }
        } else {
            throw "File at path \(self.filePath) does not exist!"
        }
    }
    
    override func parseData() throws {
        // get the files
        let url = Bundle.main.url(forResource: "replacement", withExtension: ".materialrecipe")
        let color: CIColor = CIColor(color: UIColor(col))
        
        // set the colors
        if url != nil {
            do {
                let plistData = try Data(contentsOf: url!)
                var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                
                if var firstLevel = plist["baseMaterial"] as? [String : Any], var secondLevel = firstLevel["tinting"] as? [String: Any], var thirdLevel = secondLevel["tintColor"] as? [String: Any] {
                    // set the colors
                    thirdLevel["red"] = color.red
                    thirdLevel["green"] = color.green
                    thirdLevel["blue"] = color.blue
                    thirdLevel["alpha"] = 1
                    
                    if var secondLevel2 = firstLevel["materialFiltering"] as? [String: Any] {
                        if blur == -1 {
                            firstLevel.removeValue(forKey: "materialFiltering")
                        } else {
                            secondLevel2["blurRadius"] = blur
                            firstLevel["materialFiltering"] = secondLevel2
                        }
                    }
                    
                    secondLevel["tintColor"] = thirdLevel
                    secondLevel["tintAlpha"] = color.alpha
                    firstLevel["tinting"] = secondLevel
                    plist["baseMaterial"] = firstLevel
                }
                
                if usesStyles {
                    let styles: [String: String] = [
                        "fill": fill,
                        "stroke": stroke
                    ]
                    plist["styles"] = styles
                    plist["materialSettingsVersion"] = 2
                }
                
                // fill with empty data
                // get original data
                let newUrl = URL(fileURLWithPath: filePath)
                do {
                    let originalFileSize = try Data(contentsOf: newUrl).count
                    let newData = try addEmptyData(matchingSize: originalFileSize, to: plist)
                    // save file to background directory
                    if newData.count == originalFileSize {
                        self.replacementData = newData
                    } else {
                        print(newData.count)
                        print(originalFileSize)
                        print("NOT CORRECT SIZE")
                    }
                } catch {
                    print(error.localizedDescription)
                    throw error.localizedDescription
                }
            }
        } else {
            throw "Could not find original resource url"
        }
    }
    
    init(operationName: String, author: String = "", filePath: String, applyInBackground: Bool, backupData: Data? = nil, active: Bool = true, color: Color = Color.gray, blur: Double = 30, usesStyles: Bool = false, _ fill: String = "", _ stroke: String = "") {
        self.col = color
        self.blur = blur
        self.usesStyles = usesStyles
        self.fill = fill
        self.stroke = stroke
        super.init(operationName: operationName, author: author, filePath: filePath, applyInBackground: applyInBackground, backupData: backupData, active: active)
    }
}
