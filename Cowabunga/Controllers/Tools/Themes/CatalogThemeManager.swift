////
////  CatalogThemeManager.swift
////  TrollTools
////
////  Created by exerhythm on 22.10.2022.
////
//
//import Foundation
//import UIKit
//import AssetCatalogWrapper
//
//class CatalogThemeManager {
//    
//    var fm = FileManager.default
//    
//    func applyChanges(_ changes: [ThemeManager.UserAppIconChange], progress: (Double) -> ()) throws {
//        let changesCount = Double(changes.count)
//        for (i,change) in changes.enumerated() {
//            try? applyChange(change)
//            progress(Double(i) / changesCount)
//        }
//    }
//    
//    private func applyChange(_ change: ThemeManager.UserAppIconChange) throws {
//        let appURL = change.bundleURL
//        let catalogURL = appURL.appendingPathComponent("Assets.car")
//
//        if let iconURL = change.themeIconURL {
//            // MARK: Apply custom icon
//            
//            // Backup ass :troll:
//            let backupURL = try backupAssetsURL(appURL: appURL)
//            
//            // Restore broken apps from backup
//            if !fm.fileExists(atPath: catalogURL.path) {
//                if fm.fileExists(atPath: backupURL.path) {
//                    try RootHelper.copy(from: backupURL, to: catalogURL)
//                } else { return }
//            }
//            
//            // Create backup if not made
//            if !fm.fileExists(atPath: backupURL.path) {
//                try RootHelper.copy(from: catalogURL, to: backupURL)
//            }
//            
//            // Get CGImage from icon
//            let imgData = try Data(contentsOf: iconURL)
//            guard let image = UIImage(data: imgData) else { return }
//            guard let cgImage = image.cgImage else { return }
//            
//            // Apply new icon
//            try modifyIconInCatalog(url: catalogURL, to: cgImage)
//        } else {
//            // MARK: Revert icon
//            guard fm.fileExists(atPath: catalogURL.path) else { return }
//            let backupURL = try backupAssetsURL(appURL: appURL)
//            guard fm.fileExists(atPath: backupURL.path) else { return }
//            try RootHelper.removeItem(at: catalogURL)
//            try RootHelper.move(from: backupURL, to: catalogURL)
//        }
//    }
//    
//    func restoreCatalogs(progress: (String) -> ()) throws {
//        guard let apps = LSApplicationWorkspace.default().allApplications() else { throw "Couldn't get apps" }
//        let appCount = apps.count
//        for (i, app) in apps.enumerated() {
//            progress("Restoring app #\(i)/\(appCount)")
//            guard let appURL = app.bundleURL else { continue }
//            let catalogURL = appURL.appendingPathComponent("Assets.car")
//            
//            // check if it's in /var
//            guard appURL.pathComponents.count >= 1 && (appURL.pathComponents[1] == "var" || appURL.pathComponents[1] == "private") else { continue }
//            
//            guard fm.fileExists(atPath: catalogURL.path) else { continue }
//            let backupURL = try backupAssetsURL(appURL: appURL)
//            guard fm.fileExists(atPath: backupURL.path) else { continue }
//            try RootHelper.removeItem(at: catalogURL)
//            try RootHelper.move(from: backupURL, to: catalogURL)
//        }
//    }
//    
//    func modifyIconInCatalog(url: URL, to icon: CGImage) throws { // icon: CGImage
//        let tempAssetDir = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/temp-assets-\(UUID()).car")
//        try RootHelper.move(from: url, to: tempAssetDir)
//        defer {
//            try? RootHelper.move(from: tempAssetDir, to: url)
//        }
//
//        try RootHelper.setPermission(url: tempAssetDir)
//
//        let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: tempAssetDir)
//        for rendition in renditionsRoot {
//            let type = rendition.type
//            guard type == .icon else { continue }
//            let renditions = rendition.renditions
//            for rend in renditions {
//                do {
//                    try catalog.editItem(rend, fileURL: tempAssetDir, to: .image(icon))
//                } catch {
////                    remLog("failed to edit rendition: \(error) \(rend.type) \(rend.name) \(rend.namedLookup)")
//                }
//            }
//        }
//    }
//    
//    private func backupAssetsURL(appURL: URL) throws -> URL {
//        // Get version of app, so when app updates and user restores assets.car, old
//        guard let infoPlistData = try? Data(contentsOf: appURL.appendingPathComponent("Info.plist")), let plist = try? PropertyListSerialization.propertyList(from: infoPlistData, format: nil) as? [String:Any] else { throw "Couldn't read template webclip plist" }
//        guard let appShortVersion = (plist["CFBundleShortVersionString"] as? String) ?? plist["CFBundleVersion"] as? String else { throw "CFBundleShortVersionString missing for \(appURL.path)" }
//        return appURL.appendingPathComponent("TrollToolsAssetsBackup-\(appShortVersion).car")
//    }
//}
