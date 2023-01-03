//
//  WriteFile.swift
//  Santander
//
//  Created by Mineek on 01/01/2023.
//

import Foundation
@_exported import FSOperations

struct RootConf: RootHelperConfiguration {
    var useRootHelper: Bool = true
    
    private init() {}
    
    static let shared = RootConf()
    
    func perform(_ operation: FSOperation) throws {
        switch operation {
        case .writeData(let url, let data):
            try overwriteFile(data, url.path)
        case .writeString(let url, let string):
            try overwriteFile(string.data(using: .utf8)!, url.path)
        default:
            break
        }
    }
    
    func contents(of path: URL) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
    }
}
