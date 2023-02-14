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
    
    var errors: [String] = []
    
    public init() { }
    
    public func applyChanges(_ changes: [AppIconChange], progress: (Double) -> ()) throws {
        errors.removeAll()
        try? fm.createDirectory(at: originalIconsDir, withIntermediateDirectories: true)
        
        
        let changesCount = Double(changes.count)
        for (i,change) in changes.enumerated() {
            do {
                try applyChange(change)
            } catch {
                errors.append(error.localizedDescription)
            }
            progress(Double(i) / changesCount)
        }
    }
    
    private func applyChange(_ change: AppIconChange) throws {
        let systemAppsWith💀Symlinks = ["com.apple.MBHelperApp"]
        guard !systemAppsWith💀Symlinks.contains(change.app.bundleIdentifier) else { return }
        
        backupPNGs(app: change.app)
        
        let appURL = change.app.bundleURL
        let catalogURL = appURL.appendingPathComponent("Assets.car")

        if let icon = change.icon {
            // MARK: set custom icons
            print("setting icon")
            
            try? fm.createDirectory(at: processedThemesDir.appendingPathComponent(icon.themeName), withIntermediateDirectories: true)
            for iconName in change.app.pngIconPaths {
                
                let iconURL = change.app.bundleURL.appendingPathComponent(iconName)
                
                // optimize icons if not aleady cached
                let cachedIconURL = icon.cachedThemeIconURL(fileName: iconName)
                var cachedIcon = try? Data(contentsOf: cachedIconURL)
                
                if cachedIcon == nil {
                    let imgData = try Data(contentsOf: icon.rawThemeIconURL)
                    guard let themeIcon = UIImage(data: imgData) else { throw "Could not read image data from icon at path \(icon.rawThemeIconURL.path)" }
                    
                    guard let origImageData = try? Data(contentsOf: iconURL) else { print("icon not found at the specified path. \(iconName)"); continue } // happens for calendar for some reason
                    let origImageSize = origImageData.count
                    
                    guard let origImage = UIImage(data: origImageData) else { throw "Could not read image data from original icon at path \(icon.rawThemeIconURL.path)" }
                    let width = origImage.size.width / 2
                    
                    var processedImage: Data?
                    
                    var resScale: CGFloat = 1
                    while resScale > 0.01 {
                        let sizeWithAppliedScale = width * resScale
                        let size = CGSize(width: sizeWithAppliedScale, height: sizeWithAppliedScale)
                        
                        processedImage = try? UIGraphicsImageRenderer(size: size).image { _ in themeIcon.draw(in: CGRect(origin: .zero, size: size)) }.resizeToApprox(allowedSizeInBytes: origImageSize)
                        if processedImage != nil { break }
                        
                        resScale *= 0.75
                    }
                    
                    guard let processedImage = processedImage else {
                        print("could not compress image low enough to fit inside original \(origImageData.count) bytes. path to orig \(iconURL.path), path to theme icon \(iconURL.path)")
                        continue
                    }
                    cachedIcon = processedImage
                    try! cachedIcon?.write(to: cachedIconURL)
                }
#if targetEnvironment(simulator)
#else
                let success = MDC.overwriteFile(at: iconURL.path, with: cachedIcon!)
                print(success)
                try? MDC.toggleCatalogCorruption(at: catalogURL.path, corrupt: true)
                UserDefaults.standard.set(true, forKey: "shouldPerformCatalogFixup")
#endif
            }
        } else {
            // MARK: restore icons to original
            print("restoring")
            
            for iconName in change.app.pngIconPaths {
                let iconURL = change.app.bundleURL.appendingPathComponent(iconName)
                let urlOfOriginal = change.app.originalIconURL(fileName: iconName)
                if let data = try? Data(contentsOf: urlOfOriginal) {
                    // Has backup
#if targetEnvironment(simulator)
#else
                    let success = MDC.overwriteFile(at: iconURL.path, with: data)
                    print(success)
#endif
                }
            }
        }
    }
    
    static func uncorruptCatalogs() throws {
        for app in try ApplicationManager.getApps() {
            let catalogURL = app.bundleURL.appendingPathComponent("Assets.car")
            print(app.bundleIdentifier)
            try? MDC.toggleCatalogCorruption(at: catalogURL.path, corrupt: false)
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
    
    private func backupPNGs(app: SBApp) {
        for pngIconPath in app.pngIconPaths {
            let url = app.bundleURL.appendingPathComponent(pngIconPath)
            try? fm.copyItem(at: url, to: app.originalIconURL(fileName: pngIconPath))
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
    var app: SBApp
    var icon: ThemedIcon?
    
    init(app: SBApp, icon: ThemedIcon?) {
        self.app = app
        self.icon = icon
    }
}
