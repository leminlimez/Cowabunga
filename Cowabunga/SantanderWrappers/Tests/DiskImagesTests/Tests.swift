//
//  Tests.swift
//  
//
//  Created by Serena on 24/10/2022
//
	

import XCTest
@testable import DiskImagesWrapper

class Tests: XCTestCase {
    var handleForAttachedDiskImage: DeviceHandle? = nil
    
    func testAttachDiskImage() throws {
        let diskImagePath = try getEnv("DISK_IMAGE_TO_ATTACH_FULL_PATH")
        let diskImageURL = URL(fileURLWithPath: diskImagePath)
        
        let handle = try DiskImages.shared.attachDiskImage(with: AttachParameters(itemURL: diskImageURL))
        print(handle) // print handle description
        XCTAssert(FileManager.default.fileExists(atPath: handle.deviceHandlePath.path), "Device handle path does NOT exist.") // make sure the handle path exists
        handleForAttachedDiskImage = handle
    }
    
}

extension Tests {
    func getEnv(_ name: String) throws -> String {
        guard let envValue = getenv(name) else {
            throw Errors.envVarDoesntExist(name: name)
        }
        
        return String(cString: envValue)
    }
    
    enum Errors: Error, LocalizedError {
        case envVarDoesntExist(name: String)
        case other(description: String)
        
        var errorDescription: String? {
            switch self {
            case .envVarDoesntExist(let name):
                return "Enviroment variable \(name) doesn't exist, please set it through Xcode."
            case .other(let description):
                return description
            }
        }
    }
}
