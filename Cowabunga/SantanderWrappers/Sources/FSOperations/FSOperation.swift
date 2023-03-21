//
//  FSOperation.swift
//  Santander
//
//  Created by Serena on 15/09/2022
//


import Foundation
import AssetCatalogWrapper
import UniformTypeIdentifiers

// You may ask, hey, why is this an enum and not a struct / class with several functions?
// well:
// 1) this allows for just one unified function, rather than many
// 2) this allows to redirect to a root helper

/// Lists operations that can be done to the FileSystem
public enum FSOperation: Codable {
    case removeItems(items: [URL])
    case createFile(files: [URL])
    case createDirectory(directories: [URL])
    
    case moveItem(items: [URL], resultPath: URL)
    case copyItem(items: [URL], resultPath: URL)
    case symlink (items: [URL], resultPath: URL)
    case rename  (item: URL, newPath: URL)
    
    case setOwner(url: URL, newOwner: String)
    case setGroup(url: URL, newGroup: String)
    
    case setPermissions(url: URL, newOctalPermissions: Int)
    
    case writeData(url: URL, data: Data)
    case writeString(url: URL, string: String)
    case extractCatalog(catalogFileURL: URL, resultPath: URL)
    
    static private let fm = FileManager.default
    
    private static func _returnFailedItemsDictionaryIfAvailable(_ urls: [URL], handler: (URL) throws -> Void) throws {
        if urls.count == 1 {
            try handler(urls[0])
            return
        }
        
        var failedItems: [String: String] = [:]
        for url in urls {
            do {
                try handler(url)
            } catch {
                failedItems[url.lastPathComponent] = error.localizedDescription
            }
        }
        
        if !failedItems.isEmpty {
            var message: String = ""
            for (item, error) in failedItems {
                message.append("\(item): \(error)\n")
            }
            
            throw _Errors.otherError(description: message.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    public static func perform(_ operation: FSOperation, rootHelperConf: RootHelperConfiguration?) throws {
        if let rootHelperConf = rootHelperConf, rootHelperConf.useRootHelper {
            try rootHelperConf.perform(operation)
            return
        }
       
        switch operation {
        case .removeItems(let items):
            try _returnFailedItemsDictionaryIfAvailable(items) { url in
                try fm.removeItem(at: url)
            }
            
        case .createFile(let files):
            try _returnFailedItemsDictionaryIfAvailable(files) { url in
                // mode "a": create if it doesn't exist
                guard let filePtr = fopen((url as NSURL).fileSystemRepresentation, "a") else {
                    throw _Errors.errnoError
                }
                
                fclose(filePtr)
            }
        case .createDirectory(let directories):
            try _returnFailedItemsDictionaryIfAvailable(directories) { url in
                try fm.createDirectory(at: url, withIntermediateDirectories: true)
            }
        case .moveItem(let items, let resultPath):
            try _returnFailedItemsDictionaryIfAvailable(items) { url in
                try fm.moveItem(at: url, to: resultPath.appendingPathComponent(url.lastPathComponent))
            }
        case .copyItem(let items, let resultPath):
            try _returnFailedItemsDictionaryIfAvailable(items) { url in
                try fm.copyItem(at: url, to: resultPath.appendingPathComponent(url.lastPathComponent))
            }
        case .rename(let item, let newPath):
            try FileManager.default.moveItem(at: item, to: newPath)
        case .symlink(let items, let resultPath):
            try _returnFailedItemsDictionaryIfAvailable(items) { url in
                try fm.createSymbolicLink(at: resultPath.appendingPathComponent(url.lastPathComponent), withDestinationURL: url)
            }
        case .setOwner(let url, let newOwner):
            try fm.setAttributes([.ownerAccountName: newOwner], ofItemAtPath: url.path)
        case .setGroup(let url, let newGroup):
            try fm.setAttributes([.groupOwnerAccountName: newGroup], ofItemAtPath: url.path)
        case .setPermissions(let url, let newOctalPermissions):
            try fm.setAttributes([.posixPermissions: newOctalPermissions], ofItemAtPath: url.path)
        case .writeData(let url, let data):
            try data.write(to: url)
        case .writeString(let url, let string):
            try string.write(to: url, atomically: true, encoding: .utf8)
        case .extractCatalog(let catalogFileURL, let resultPath):
            let (_, nonCodableRends) = try AssetCatalogWrapper.shared.renditions(forCarArchive: catalogFileURL)
            let renditions = nonCodableRends.flatMap(\.renditions).toCodable()
            
            try fm.createDirectory(at: resultPath, withIntermediateDirectories: true)
            var failedItems: [String: String] = [:]
            for rend in renditions {
                let newURL = resultPath.appendingPathComponent(rend.renditionName)
                if let data = rend.itemData {
                    do {
                        try FSOperation.perform(.writeData(url: newURL, data: data), rootHelperConf: rootHelperConf)
                    } catch {
                        failedItems[rend.renditionName] = "Unable to write item data to file: \(error.localizedDescription)"
                    }
                }
            }
            
            if !failedItems.isEmpty {
                var message: String = ""
                for (item, error) in failedItems {
                    message.append("\(item): \(error)")
                }
                
                throw _Errors.otherError(description: message.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
    
    /// The command line invokation to use for SantanderRootHelper
    /// for this operation
    public var commandLineInvokation: [String] {
        switch self {
        case .removeItems(let items):
            return ["delete", items.joined()]
        case .createFile(let files):
            return ["create", "--files", files.joined()]
        case .createDirectory(let directories):
            return ["create", "--directories", directories.joined()]
        case .moveItem(let items, let resultPath):
            return ["move", items.joined(), "--destination", resultPath.path]
        case .copyItem(let items, let resultPath):
            return ["copy", items.joined(), "--destination", resultPath.path]
        case .rename(let item, let newPath):
            return ["rename", item.path, newPath.path]
        case .symlink(let items, let resultPath):
            return ["link", items.joined(), "--destination", resultPath.path]
        case .setOwner(let url, let newOwner):
            return ["set-owner-or-group", url.path, "--owner-name", newOwner]
        case .setGroup(let url, let newGroup):
            return ["set-owner-or-group", url.path, "--group-name", newGroup]
        case .setPermissions(let url, let newOctalPermissions):
            return ["set-permissions", url.path, newOctalPermissions.description]
        case .writeData(let url, _):
            return ["write-data", url.path]
        case .writeString(let url, let string):
            return ["write-string", string, "--path", url.path]
        case .extractCatalog(let catalogFile, let resultPath):
            return ["extract-catalog", catalogFile.path, "--destination", resultPath.path]
        }
    }
}

private extension Array where Element == URL {
    func joined(separator: String = " ") -> String {
        map(\.path).joined(separator: separator)
    }
}

private enum _Errors: Error, LocalizedError {
    case errnoError
    case otherError(description: String)
    
    var errorDescription: String? {
        switch self {
        case .errnoError:
            return String(cString: strerror(errno))
        case .otherError(let description):
            return description
        }
    }
}
