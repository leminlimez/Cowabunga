//
//  Tests.swift
//  
//
//  Created by Serena on 21/10/2022
//

@testable import CompressionWrapper
import libarchiveBridge
import XCTest

class CompressionTests: XCTestCase {
    let currentFileURL = URL(fileURLWithPath: #file)
    
    func testExtraction() throws {
        let fileToExtract = URL(fileURLWithPath: try getEnv("FILE_TO_EXTRACT_PATH"))
        let destinationURL = currentFileURL.deletingLastPathComponent().appendingPathComponent("Output")
        defer {
            for content in (try? FileManager.default.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: [])) ?? [] {
                try? FileManager.default.removeItem(at: content)
            }
        }
        
        try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        
        try Compression.shared.extract(path: fileToExtract, to: destinationURL)
    }
    
    // Test to make sure we get the "Failed to open archive file" when a file doesn't exist
    func testExtractionPathDoesntExist() throws {
        // this path obviously doesn't exist, so lets try and make sure we get the "failed to open file"
        let archiveThatDoesntExist = URL(fileURLWithPath: "/Kendrick/Savior.zip")
        let destination = URL(fileURLWithPath: NSTemporaryDirectory()) // nothing'll  get archived, so this doesn't matter
        
        XCTAssertThrowsError(try Compression.shared.extract(path: archiveThatDoesntExist, to: destination))
    }
    
    func testArchive() throws {
        let parentDir = currentFileURL.deletingLastPathComponent()
        let paths = [
            parentDir.appendingPathComponent("Tests.swift"),
            parentDir.appendingPathComponent("TestFile.swift"),
            URL(fileURLWithPath: "/Users/user/Public")
        ]
        
        try Compression.shared.compress(paths: paths, outputPath: parentDir.appendingPathComponent("Output.zip"), format: .tar)
    }
    
    func testBothArchiveAndExtract() throws {
        let parentPath = currentFileURL.deletingLastPathComponent()
        try testArchive()
        try Compression.shared.extract(path: parentPath.appendingPathComponent("Output.zip"), to: parentPath.appendingPathComponent("Output"))
    }
    
    func getEnv(_ variable: String) throws -> String {
        guard let value = getenv(variable) else {
            throw TestErrors.unableToGetEnv(envVarName: variable)
        }
        
        return String(cString: value)
    }
}


private enum TestErrors: Error, LocalizedError, CustomStringConvertible {
    case unableToGetEnv(envVarName: String)
    
    var description: String {
        switch self {
        case .unableToGetEnv(let envVarName):
            return "Unable to get enviroment variable \(envVarName)"
        }
    }
    
    var errorDescription: String? {
        description
    }
}
