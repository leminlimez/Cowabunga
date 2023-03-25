//
//  ApplicationManager.swift
//  Cowabunga
//
//  Created by sourcelocation on 03/02/2023.
//

import UIKit
import MacDirtyCowSwift
import AssetCatalogWrapper


// code from appabetical
class ApplicationManager {
    private static var fm = FileManager.default
    
    private static let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    static func getApps() throws -> [SBApp] {
        var dotAppDirs: [URL] = []
        
        let systemAppsDir = try fm.contentsOfDirectory(at: systemApplicationsUrl, includingPropertiesForKeys: nil)
        dotAppDirs += systemAppsDir
        let userAppsDir = try fm.contentsOfDirectory(at: userApplicationsUrl, includingPropertiesForKeys: nil)
        
        for userAppFolder in userAppsDir {
            let userAppFolderContents = try fm.contentsOfDirectory(at: userAppFolder, includingPropertiesForKeys: nil)
            if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
                dotAppDirs.append(dotApp)
            }
        }
        
        var apps: [SBApp] = []
        
        for bundleUrl in dotAppDirs {
            let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
            if !fm.fileExists(atPath: infoPlistUrl.path) {
                // some system apps don't have it, just ignore it and move on.
                continue
            }
            
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { throw "Error opening info.plist for \(bundleUrl.absoluteString)" }
            guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { throw "No bundle ID for \(bundleUrl.absoluteString)" }
            var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", version: infoPlist["CFBundleShortVersionString"] as? String ?? "1", bundleURL: bundleUrl, pngIconPaths: [], hiddenFromSpringboard: false)
            
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { throw "Error reading display name for \(bundleUrl.absoluteString)" }
                app.name = CFBundleDisplayName
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { throw "Error reading name for \(bundleUrl.absoluteString)" }
                app.name = CFBundleName
            }
            
            // obtaining png icons inside bundle. defined in info.plist
            if app.bundleIdentifier == "com.apple.mobiletimer" {
                // use correct paths for clock, because it has arrows
                app.pngIconPaths += ["circle_borderless@2x~iphone.png"]
            }
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String : AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png"}
                    }
                    if let CFBundleIconName = CFBundlePrimaryIcon["CFBundleIconName"] as? String {
                        app.plistIconName = CFBundleIconName
                    }
                }
            }
            if infoPlist.keys.contains("CFBundleIconFile") {
                // happens in the case of pseudo-installed apps
                if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                    app.pngIconPaths.append(CFBundleIconFile + ".png")
                }
            }
            if infoPlist.keys.contains("CFBundleIconFiles") {
                // only seen this happen in the case of Wallet
                if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                    app.pngIconPaths += CFBundleIconFiles.map { $0.replacingOccurrences(of: ".png", with: "") + ".png" }
                }
            }
            
            // check if app is hidden
            if let SBAppTags = infoPlist["SBAppTags"] as? [String], !SBAppTags.isEmpty {
                if SBAppTags.contains("hidden") {
                    app.hiddenFromSpringboard = true
                }
            }
            
            apps.append(app)
        }
        
        return apps
    }
}

struct SBApp {
    private let fm = FileManager.default
    
    var bundleIdentifier: String
    var name: String
    var version: String
    var bundleURL: URL
    
    var plistIconName: String?
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
    
    var isSystem: Bool {
        bundleURL.pathComponents.count >= 2 && bundleURL.pathComponents[1] == "Applications"
    }
    
    func catalogIconName() -> String? {
        if bundleIdentifier == "com.apple.mobiletimer" {
            return "ClockIconBackgroundSquare"
        } else {
            return plistIconName
        }
    }
    func assetsCatalogURL() -> URL {
        if bundleIdentifier == "com.apple.mobiletimer" {
            return URL(fileURLWithPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/Assets.car")
        } else {
            return bundleURL.appendingPathComponent("Assets.car")
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
    
    func backUpPNGIcons() {
        for pngIconPath in pngIconPaths {
            let oldURL = originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + pngIconPath)
            
            if fm.fileExists(atPath: oldURL.path) {
                try? fm.moveItem(at: oldURL, to: backupIconURL(fileName: pngIconPath))
            } else {
                let url = bundleURL.appendingPathComponent(pngIconPath)
                try? fm.copyItem(at: url, to: backupIconURL(fileName: pngIconPath))
            }
        }
    }
    
    /// Method for obtaining the url for new backups
    func backupIconURL(fileName: String) -> URL {
        originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + version + "----"  + fileName)
    }
    
    /// Method for obtaining the url for already exisitng backups, including support for old versions
    func backedUpIconURL(fileName: String) -> URL? {
        let newURL = backupIconURL(fileName: fileName)
        let oldURL = originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + fileName)
        
        if fm.fileExists(atPath: newURL.path) {
            return newURL
        } else if fm.fileExists(atPath: newURL.path) {
            return oldURL
        } else {
            return nil
        }
    }
    func catalogBackupURL() -> URL {
        catalogBackupsDir.appendingPathComponent(bundleIdentifier + "----" + version).appendingPathExtension("car.part")
    }
    
    func restorePNGIcons() throws {
        for iconName in pngIconPaths {
            autoreleasepool {
                let iconURL = bundleURL.appendingPathComponent(iconName)
                guard let urlOfOriginal = backedUpIconURL(fileName: iconName) else { return }
                if let data = try? Data(contentsOf: urlOfOriginal) {
                    // Has backup
                    try? MDC.overwriteFile(at: iconURL.path, with: data)
                    // ^ has to have a ? due to me being dumb and not including versions of app that backed up icon was from, and it may be larger in size
                }
            }
        }
    }
    func restoreCatalog() throws {
        try autoreleasepool {
            let catalogBackupURL = catalogBackupURL()
            guard FileManager.default.fileExists(atPath: catalogBackupURL.path) else { return }
            let catalogURL = bundleURL.appendingPathComponent("Assets.car")
            
            try MDC.overwriteFile(at: catalogURL.path, with: try Data(contentsOf: catalogBackupURL), unlockDataAtEnd: !isSystem)
            // verify that it is not corrupted, as long as it is not a system path
            if bundleURL.lastPathComponent != "MobileTimer.app" {
                do {
                    let _ = try AssetCatalogWrapper.shared.renditions(forCarArchive: catalogBackupURL)
                    do {
                        let _ = try AssetCatalogWrapper.shared.renditions(forCarArchive: catalogURL)
                    } catch {
                        ERRORED_APP = bundleURL.lastPathComponent
                        throw MDC.MDCOverwriteError.corruption
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setPNGIcons(icon: ThemedIcon) throws {
        for iconName in pngIconPaths {
            try autoreleasepool {
                let iconURL = bundleURL.appendingPathComponent(iconName)
                
                // optimize icons if not aleady cached
                let cachedIconURL = icon.cachedThemeIconURL(fileName: iconName)
                var cachedIcon = try? Data(contentsOf: cachedIconURL)
                
                if cachedIcon == nil {
                    let imgData = try Data(contentsOf: icon.rawThemeIconURL)
                    guard let themeIcon = UIImage(data: imgData) else { throw "Could not read image data from icon at path \(icon.rawThemeIconURL.path)" }
                    
                    guard let origImageData = try? Data(contentsOf: iconURL) else { print("icon not found at the specified path. \(iconName)"); return } // happens for calendar for some reason
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
                        return
                    }
                    cachedIcon = processedImage
                    try! cachedIcon?.write(to: cachedIconURL)
                }
                try? MDC.overwriteFile(at: iconURL.path, with: cachedIcon!, unlockDataAtEnd: !isSystem)
                //            try? MDC.toggleCatalogCorruption(at: catalogURL.path, corrupt: true)
            }
        }
    }
}
