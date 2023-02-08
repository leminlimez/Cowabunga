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
            return newURL
        } catch {
            print("An error occurred getting/making the saved operations directory")
        }
        return nil
    }
}
