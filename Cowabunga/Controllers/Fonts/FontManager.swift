//
//  FontManager.swift
//  Cowabunga
//
//  Created by lemin on 2/22/23.
//

import Foundation

class FontManager {
    static func getSavedFontsFolder() throws -> URL {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Saved_Fonts")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            throw "An error occurred getting/making the saved operations directory"
        }
    }
    
    static func deleteFontPack(_ name: String) throws {
        let savedPath = try getSavedFontsFolder()
        let fontPack = savedPath.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: fontPack.path) {
            try FileManager.default.removeItem(at: fontPack)
            return
        }
    }
    
    static func createFontPackFolder(_ name: String) throws {
        let savedPath = try getSavedFontsFolder()
        if !FileManager.default.fileExists(atPath: savedPath.appendingPathComponent(name).path) {
            try FileManager.default.createDirectory(at: savedPath.appendingPathComponent(name), withIntermediateDirectories: false)
        } else {
            throw "Font pack with name \(name) already exists!"
        }
    }
    
    static func getFontPacks() throws -> [FontPack] {
        let savedPath = try getSavedFontsFolder()
        var fp: [FontPack] = []
        for file in try FileManager.default.contentsOfDirectory(at: savedPath, includingPropertiesForKeys: nil) {
            fp.append(.init(name: file.lastPathComponent))
        }
        return fp
    }
}
