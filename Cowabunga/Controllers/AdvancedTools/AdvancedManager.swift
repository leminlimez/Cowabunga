//
//  AdvancedManager.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation

class AdvancedManager {
    func getSavedOperationsDirectory() -> URL? {
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
    
    func createUnnamedFolder(folderURL: URL) {
        do {
            let unnamedURL = folderURL.appendingPathComponent("Unnamed")
            if !FileManager.default.fileExists(atPath: unnamedURL.path) {
                try FileManager.default.createDirectory(at: unnamedURL, withIntermediateDirectories: false)
            }
        } catch {
            print("An error occurred making unnamed directory")
        }
    }
}
