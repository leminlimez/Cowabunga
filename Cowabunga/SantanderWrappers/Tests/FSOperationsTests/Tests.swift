//
//  Tests.swift
//  
//
//  Created by Serena on 18/10/2022
//


@testable import FSOperations
import AssetCatalogWrapper
import XCTest

// todo: more tests?
class FSOperationTests: XCTestCase {
    let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
    let homeDir = URL(fileURLWithPath: NSHomeDirectory())
    
    lazy var filesToManage = ["file 1", "file 2", Bundle.main.bundleIdentifier!].map { fileName in
        tmpDir.appendingPathComponent(fileName)
    }
    
    lazy var directoriesToManage = ["Directory1", "Directory2", Int.random(in: 1...100).description].map { directoryName in
        tmpDir.appendingPathComponent(directoryName)
    }
    
    func testInOrder() throws {
        try testCreatePaths()
        try testCreateSymlinks()
        try testRemovePaths()
    }
    
    func testCreatePaths() throws {
        filesToManage.printPaths()
        try FSOperation.perform(.createFile(files: filesToManage), rootHelperConf: nil)
        try ensurePathsExist(filesToManage)
        
        directoriesToManage.printPaths()
        try FSOperation.perform(.createDirectory(directories: directoriesToManage), rootHelperConf: nil)
        try ensurePathsExist(directoriesToManage)
    }
    
    func testRemovePaths() throws {
        try ensurePathsExist(filesToManage)
        try ensurePathsExist(directoriesToManage)
        
        try FSOperation.perform(.removeItems(items: filesToManage), rootHelperConf: nil)
        try FSOperation.perform(.removeItems(items: directoriesToManage), rootHelperConf: nil)
    }
    
    func testCreateSymlinks() throws {
        try ensurePathsExist(filesToManage)
        
        try FSOperation.perform(.symlink(items: filesToManage, resultPath: homeDir), rootHelperConf: nil)
    }
}

extension FSOperationTests {
    func ensurePathsExist(_ paths: [URL]) throws {
        let pathsThatDontExist = paths.filter { path in
            return !FileManager.default.fileExists(atPath: path.path)
        }
        
        if !pathsThatDontExist.isEmpty {
            throw StringError("ERROR: Paths \(pathsThatDontExist) are supposed to exist, BUT DON'T!")
        }
    }
}

extension Array where Element == URL {
    func printPaths(seperator: String = ", ") {
        print(map(\.path).joined(separator: seperator))
    }
}

internal struct StringError: Error, LocalizedError, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        return description
    }
}
