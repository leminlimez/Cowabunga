//
//  AdvancedObject.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation
import MacDirtyCowSwift

enum ReplacingObjectType: String {
    case FilePath = "File Path"
    case Imported = "Imported"
}

class AdvancedCategory: Identifiable {
    var id = UUID()
    
    var categoryName: String
    var categoryOperations: [AdvancedObject]
    
    init(categoryName: String, categoryOperations: [AdvancedObject]) {
        self.categoryName = categoryName
        self.categoryOperations = categoryOperations
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
    
    func parseData() {
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

class CorruptingObject: AdvancedObject {
    override func parseData() {
        // create empty data
        self.replacementData = Data("#".utf8)
    }
}

class ReplacingObject: AdvancedObject {
    var replacingType: ReplacingObjectType
    var replacingPath: String
    
    init(operationName: String, filePath: String, singleApply: Bool, applyInBackground: Bool, overwriteData: Data, replacingType: ReplacingObjectType, replacingPath: String) {
        self.replacingType = replacingType
        self.replacingPath = replacingPath
        super.init(operationName: operationName, filePath: filePath, singleApply: singleApply, applyInBackground: applyInBackground)
        self.replacementData = overwriteData
    }
}
