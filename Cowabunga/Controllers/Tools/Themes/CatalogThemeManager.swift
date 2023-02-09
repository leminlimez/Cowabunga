//
//  CatalogThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import Foundation
import UIKit
import MacDirtyCowSwift

public class CatalogThemeManager {
    
    var fm = FileManager.default
    
    public init() { }
    
    public func applyChanges(_ changes: [AppIconChange], progress: (Double) -> ()) throws {
        let changesCount = Double(changes.count)
        for (i,change) in changes.enumerated() {
            try! applyChange(change)
            progress(Double(i) / changesCount)
        }
    }
    
    private func applyChange(_ change: AppIconChange) throws {
        backupPNG(bundleURL: change.bundleURL, pngIconPaths: change.pngIconPaths, id: change.bundleIdentifier)
        
        let appURL = change.bundleURL
        let catalogURL = appURL.appendingPathComponent("Assets.car")

        if let iconURL = change.themeIconURL {
            // MARK: Apply custom icon
            
//            // Backup ass :troll:
//            let backupURL = try backupAssetsURL(appURL: appURL)
            
//            // Restore broken apps from backup
//            if !fm.fileExists(atPath: catalogURL.path) {
//                if fm.fileExists(atPath: backupURL.path) {
//                    try RootHelper.copy(from: backupURL, to: catalogURL)
//                } else { return }
//            }
            
//            // Create backup if not made
//            if !fm.fileExists(atPath: backupURL.path) {
//                try RootHelper.copy(from: catalogURL, to: backupURL)
//            }
            
            // Get CGImage from icon    
            let imgData = try Data(contentsOf: iconURL)
            guard let themeIcon = UIImage(data: imgData) else { return }
            
            // Apply new icon
            try MDC.toggleCatalogCorruption(at: catalogURL.path, corrupt: true)
            
            for iconName in change.pngIconPaths {
                let url = change.bundleURL.appendingPathComponent(iconName)
                
                let origImageData = try Data(contentsOf: url)
                let origImageSize = origImageData.count
                
                guard let origImage = UIImage(data: origImageData) else { continue }
                let width = origImage.size.width / UIScreen.main.scale * 1
                let size = CGSize(width: width, height: width)
                
                let res = try UIGraphicsImageRenderer(size: size).image { _ in
                    themeIcon.draw(in: CGRect(origin: .zero, size: size))
                }.resizeToApprox(allowedSizeInBytes: origImageSize)
                
                let success = MDC.overwriteFile(at: url.path, with: res)
                print(success)
            }
        }
    }
    
    
//    func corruptIconInCatalog(url: URL) throws { // icon: CGImage
//        let data = try Data(contentsOf: url)
//        let byteArray = [UInt8](data)
//
//        // MARK: This works. But RAM expensive
//        let success = MDC.overwriteFile(at: url.path, with: Data([UInt8](repeating: 1, count: byteArray.count )))
//        print(success)
        
        // MARK: ATM as expensive as the previous method due to still overwriting entire assets.car. Though can be ported to use page overwriting
//        let appIconBytes = [UInt8]("AppIcon".data(using: .utf8)!)
//        let trolleyStringBytes = [UInt8]("Tr0ll3y".data(using: .utf8)!)
//        let findBytes: [UInt8] = [65,112,112,73,99,111,110]
//        let replaceBytes: [UInt8] = [84,114,48,108,108,51,121]
//
//        var startIndex = 0
//        while startIndex <= byteArray.count - findBytes.count {
//            let endIndex = startIndex + findBytes.count
//            let subArray = Array(byteArray[startIndex..<endIndex])
//            if subArray == findBytes {
//                byteArray.replaceSubrange(startIndex..<endIndex, with: replaceBytes)
//                startIndex += replaceBytes.count
//            } else {
//                startIndex += 1
//            }
//        }
//        let newData = Data(byteArray)
////        try newData.write(to: URL.documents.appendingPathComponent("test.car"))
//
//        let success = MDC.overwriteFile(at: url.path, with: newData)
//        if !success {
//            throw "Couldn't overwrite using MDC. \(url.path)"
//        }
//    }
    
    private func backupPNG(bundleURL: URL, pngIconPaths: [String], id: String) {
        try? fm.createDirectory(at: originalIconsDir, withIntermediateDirectories: true)
        for pngIconPath in pngIconPaths {
            let url = bundleURL.appendingPathComponent(pngIconPath)
            try? fm.copyItem(at: url, to: originalIconsDir.appendingPathComponent(id + "----" + pngIconPath))
        }
    }
    
    
    struct BackedUpPNG {
        var bundleIdentifier: String
        var iconName: String
        var data: Data
    }
    
    /// bundle id, icon name in .app, img data
    private func backedUpPNGs() -> [BackedUpPNG] {
        var res: [BackedUpPNG] = []
        for url in (try? fm.contentsOfDirectory(at: originalIconsDir, includingPropertiesForKeys: nil)) ?? [] {
            let items = url.lastPathComponent.components(separatedBy: "----")
            guard let data = try? Data(contentsOf: url) else { continue }
            res.append(.init(bundleIdentifier: items[0], iconName: items[1], data: data))
        }
        return res
    }
    
//    private func backupAssetsURL(appURL: URL) throws -> URL {
//        // Get version of app, so when app updates and user restores assets.car, old
//        guard let infoPlistData = try? Data(contentsOf: appURL.appendingPathComponent("Info.plist")), let plist = try? PropertyListSerialization.propertyList(from: infoPlistData, format: nil) as? [String:Any] else { throw "Couldn't read template webclip plist" }
//        guard let appShortVersion = (plist["CFBundleShortVersionString"] as? String) ?? plist["CFBundleVersion"] as? String else { throw "CFBundleShortVersionString missing for \(appURL.path)" }
//        return appURL.appendingPathComponent("TrollToolsAssetsBackup-\(appShortVersion).car")
//    }
}

public struct AppIconChange {
    var bundleURL: URL
    var pngIconPaths: [String]
    var themeIconURL: URL?
    var bundleIdentifier: String
    
    public init(bundleURL: URL, pngIconPaths: [String], themeIconURL: URL? = nil, bundleIdentifier: String) {
        self.bundleURL = bundleURL
        self.pngIconPaths = pngIconPaths
        self.themeIconURL = themeIconURL
        self.bundleIdentifier = bundleIdentifier
    }
}
