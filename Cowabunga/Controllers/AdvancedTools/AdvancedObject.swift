//
//  AdvancedObject.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation
import MacDirtyCowSwift

enum ReplacingObjectType: String, CaseIterable {
    case FilePath = "File Path"
    case Imported = "Imported"
}

class AdvancedCategory: Identifiable {
    var id = UUID()
    var name: String
    var operations: [AdvancedCategory]?
    var categoryName: String?
    
    init(name: String, operations: [AdvancedCategory]? = nil, categoryName: String? = nil) {
        self.name = name
        self.operations = operations
        self.categoryName = categoryName
    }
}

class AdvancedObject: Identifiable {
    var id = UUID()
    
    var operationName: String
    var filePath: String
    var singleApply: Bool
    var replacementData: Data? = nil
    var applyInBackground: Bool
    
    init(operationName: String, filePath: String, singleApply: Bool, applyInBackground: Bool) {
        self.operationName = operationName
        self.filePath = filePath
        self.singleApply = singleApply
        self.applyInBackground = applyInBackground
    }
    
    func parseData() throws {
        // parse the data to be replaced
    }
    
    func applyData() throws {
        // applies the data only if it was parsed
        if replacementData != nil {
            if FileManager.default.fileExists(atPath: filePath) {
                // get data of and make sure it is smaller
                do {
                    let originalSize = try Data(contentsOf: URL(fileURLWithPath: filePath)).count
                    if originalSize <= replacementData!.count {
                        let _ = MDC.overwriteFile(at: filePath, with: replacementData!)
                    } else {
                        throw "Replacement data is larger than the original file!"
                    }
                } catch {
                    throw error.localizedDescription
                }
            } else {
                throw "No file exists at path!"
            }
        } else {
            throw "Data not parsed before applying!"
        }
    }
}

class NullObject: AdvancedObject {
    init() {
        super.init(operationName: "Null", filePath: "/", singleApply: false, applyInBackground: false)
    }
}

class CorruptingObject: AdvancedObject {
    override func parseData() throws {
        // create empty data
        self.replacementData = Data("#".utf8)
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
    
    init(operationName: String, filePath: String, singleApply: Bool, applyInBackground: Bool, overwriteData: Data, replacingType: ReplacingObjectType, replacingPath: String) {
        self.replacingType = replacingType
        self.replacingPath = replacingPath
        super.init(operationName: operationName, filePath: filePath, singleApply: singleApply, applyInBackground: applyInBackground)
        self.replacementData = overwriteData
    }
}
