//
//  FontMap.swift
//  WDBFontOverwrite
//
//  Created by Noah Little on 4/1/2023.
//

import Foundation

struct CustomFont {
    var name: String
    var targetPaths: [String]
    var localPath: String
}

enum CustomFontType: String {
    case font = "fonts"
    case emoji = "emojis"
}

struct FontMap {
    static var fontMap = [String: CustomFont]()
    
    static let emojiCustomFont = CustomFont(
        name: "Emoji",
        targetPaths: [
            "/System/Library/Fonts/CoreAddition/AppleColorEmoji-160px.ttc",
            "/System/Library/Fonts/Core/AppleColorEmoji.ttc",
        ],
        localPath: "CustomAppleColorEmoji.ttc"
    )
    
    static func populateFontMap() async throws {
        let fm = FileManager.default
        let fontDirPath = "/System/Library/Fonts/"
        
        let fontSubDirectories = try fm.contentsOfDirectory(atPath: fontDirPath)
        for dir in fontSubDirectories {
            let fontFiles = try fm.contentsOfDirectory(atPath: "\(fontDirPath)\(dir)")
            for font in fontFiles {
                guard !font.contains("AppleColorEmoji") else {
                    continue
                }
                fontMap[key(forFont: font)] = CustomFont(
                    name: font,
                    targetPaths: ["\(fontDirPath)\(dir)/\(font)"],
                    localPath: "Custom\(font)"
                )
            }
        }
    }
    
    public static func key(forFont font: String) -> String {
        var components = font.components(separatedBy: ".")
        components.removeLast()
        var rejoinedString = components.joined(separator: ".")
        if rejoinedString.hasPrefix("Custom") {
            rejoinedString = rejoinedString.replacingOccurrences(of: "Custom", with: "")
        }
        return rejoinedString
    }
}
