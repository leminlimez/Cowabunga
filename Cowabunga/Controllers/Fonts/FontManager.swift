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
    
    static func renameFontPack(old: String, new: String) throws {
        let savedPath = try getSavedFontsFolder()
        let fontPack = savedPath.appendingPathComponent(old)
        let newPack = savedPath.appendingPathComponent(new)
        if FileManager.default.fileExists(atPath: fontPack.path) {
            if !FileManager.default.fileExists(atPath: newPack.path) {
                try FileManager.default.moveItem(at: fontPack, to: newPack)
            } else {
                throw "Font pack with that name already exists!"
            }
        } else {
            throw "Could not get font pack folder!"
        }
    }
    
    static func deleteFontFile(_ name: String, _ fontPack: String) throws {
        let savedPath = try getSavedFontsFolder()
        let fontPack = savedPath.appendingPathComponent(fontPack)
        if FileManager.default.fileExists(atPath: fontPack.path) {
            if FileManager.default.fileExists(atPath: fontPack.appendingPathComponent(name).path) {
                try FileManager.default.removeItem(at: fontPack.appendingPathComponent(name))
            } else {
                print("File \(name) does not exist in folder \(fontPack.path)!")
            }
        } else {
            throw "Could not get font pack folder!"
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
    
    static func applyCurrentFont() throws {
        let pack: String = UserDefaults.standard.string(forKey: "SelectedFont") ?? "None"
        if pack != "None" {
            let fontsPath = URL(fileURLWithPath: "/System/Library/Fonts/")
            let savedPath = try getSavedFontsFolder()
            let fontPack = savedPath.appendingPathComponent(pack)
            if FileManager.default.fileExists(atPath: fontPack.path) {
                // apply each file
                for font in try FileManager.default.contentsOfDirectory(at: fontPack, includingPropertiesForKeys: nil) {
                    let replacingName: String = font.lastPathComponent
                    for fontFolder in try FileManager.default.contentsOfDirectory(at: fontsPath, includingPropertiesForKeys: nil) {
                        let replacementPath: String = fontFolder.appendingPathComponent(replacingName).path
                        if FileManager.default.fileExists(atPath: replacementPath) {
                            // replace the font
                            try OverwriteFontImpl.overwriteWithFont(fontURL: font, pathToTargetFont: replacementPath)
                        }
                    }
                }
            } else {
                throw "Could not get font pack folder!"
            }
        }
    }
    
    static func addFontFileToPack(pack: String, file: URL) throws -> FontFile {
        let savedPath = try getSavedFontsFolder()
        let fontPack = savedPath.appendingPathComponent(pack)
        if FileManager.default.fileExists(atPath: fontPack.path) {
            let fileData: Data = try Data(contentsOf: file)
            // write to file
            try fileData.write(to: fontPack.appendingPathComponent(file.lastPathComponent))
            return FontFile.init(name: file.lastPathComponent)
        } else {
            throw "Could not get font pack folder!"
        }
    }
    
    static func getFontPackFiles(_ fontPack: String) throws -> [FontFile] {
        let savedPath = try getSavedFontsFolder()
        let fontPack = savedPath.appendingPathComponent(fontPack)
        if FileManager.default.fileExists(atPath: fontPack.path) {
            var files: [FontFile] = []
            for file in try FileManager.default.contentsOfDirectory(at: fontPack, includingPropertiesForKeys: nil) {
                files.append(.init(name: file.lastPathComponent))
            }
            return files
        } else {
            throw "Could not get font pack folder!"
        }
    }
}
