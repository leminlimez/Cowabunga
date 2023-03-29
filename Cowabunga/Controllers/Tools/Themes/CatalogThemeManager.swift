//
//  CatalogThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import Foundation
import UIKit
import MacDirtyCowSwift
import AssetCatalogWrapper

public class CatalogThemeManager {
    
    var fm = FileManager.default
    
    var errors: [String] = []
    
    enum ChangeApplyError {
        case critical(Error)
        case nonCritical([Error])
    }
    
    public init() { }
    
    private func verifyCatalog(_ change: AppIconChange) -> Bool {
        let app = change.app
        
        let systemAppsWith💀Symlinks = ["com.apple.MBHelperApp"]
        guard !systemAppsWith💀Symlinks.contains(app.bundleIdentifier) else { return true }
        guard !app.hiddenFromSpringboard else { return true }
        
        let catalogURL = app.assetsCatalogURL()
        do {
            let _ = try AssetCatalogWrapper.shared.renditions(forCarArchive: catalogURL)
            return true
        } catch {
            // try to revert file
            do {
                try change.app.restoreCatalog()
                let _ = try AssetCatalogWrapper.shared.renditions(forCarArchive: catalogURL)
                return true
            } catch {
                // corruption error
                UserDefaults.standard.set(false, forKey: "noCatalogThemingFixup")
                return false
            }
        }
    }
    
    public func applyChanges(_ changes: [AppIconChange], progress: ((Double,String)) -> ()) throws -> [String] {
        themingInProgress = true
        errors.removeAll()
        try? fm.createDirectory(at: originalIconsDir, withIntermediateDirectories: true)
        try? fm.createDirectory(at: catalogBackupsDir, withIntermediateDirectories: true)
        
        
        let changesCount = Double(changes.count)
        for (i,change) in changes.enumerated() {
            do {
                let didApply = try applyChange(change)
                // verify to make sure catalog is not corrupted
                if didApply == true && !verifyCatalog(change) {
                    errors.append(MDC.MDCOverwriteError.corruption.localizedDescription)
                    MDC.isMDCSafe = false
                    break
                }
            } catch {
                errors.append(error.localizedDescription)
                if error is MDC.MDCOverwriteError {
                    break
                }
            }
            progress((Double(i) / changesCount, change.app.name))
        }
        
        if !MDC.isMDCSafe {
            throw NSLocalizedString("⛔️ Aborted ⛔️\n\n\(errors.last?.localizedDescription ?? "no error")", comment: "")
        }
        print("done", errors)
        themingInProgress = false
        
        return errors
    }
    
    private func applyChange(_ change: AppIconChange) throws -> Bool {
        try autoreleasepool {
            let app = change.app
            
            let systemAppsWith💀Symlinks = ["com.apple.MBHelperApp"]
            print(app.bundleIdentifier)
//            let systemAppsWith💀Symlinks = ["com.burbn.instagram"]
            guard !systemAppsWith💀Symlinks.contains(app.bundleIdentifier) else { return false }
            guard !app.hiddenFromSpringboard else { return false }
            
            let catalogURL = app.assetsCatalogURL()
            
            if let icon = change.icon {
                print("set")
                
                // MARK: Replace Assets.car
                if UserDefaults.standard.bool(forKey: "catalogIconTheming") {
                    if FileManager.default.fileExists(atPath: catalogURL.path) {
                        try backupCatalog(ofApp: app)
                        
                        let imgData = try Data(contentsOf: icon.rawThemeIconURL)
                        
                        guard let themeIcon = UIImage(data: imgData) else { throw "Could not read image data from icon at path \(icon.rawThemeIconURL.path)" }
                        
                        let catalogSize = getCatalogSize(originPath: catalogURL.path)
                        if let catalogIconName = app.catalogIconName() { // happens with app which store their icons as .png's inside bundle
                            let newCatalogURL = try createCatalog(withIcon: themeIcon, iconName: catalogIconName, maxSize: catalogSize, bundleIdentifier: app.bundleIdentifier)
                            UserDefaults.standard.set(true, forKey: "shouldPerformCatalogFixup")
                            try MDC.overwriteFile(at: catalogURL.path, with: try Data(contentsOf: newCatalogURL), multipleIterations: true)
                            return true
                        }
                    }
                }
                
                // MARK: Replace .png icons
                if UserDefaults.standard.bool(forKey: "pngIconTheming") {
                    app.backUpPNGIcons()
                    try? fm.createDirectory(at: processedThemesDir.appendingPathComponent(icon.themeName), withIntermediateDirectories: true)
                    try app.setPNGIcons(icon: icon)
                }
            } else {
                print("restore")
                try app.restorePNGIcons()
                try app.restoreCatalog()
            }
            return false
        }
    }
    
    private func getCatalogSize(originPath: String) -> Int {
        let fd = open(originPath, O_RDONLY | O_CLOEXEC)
        defer { close(fd) }
        return Int(lseek(fd, 0, SEEK_END))
    }
    
    private func createCatalog(withIcon rawIcon: UIImage, iconName: String, maxSize: Int, bundleIdentifier: String) throws -> URL {
        
        var resScale: CGFloat = 1
        while resScale > 0.01 {
            
            let sizeWithAppliedScale = 60 * resScale
            let size = CGSize(width: sizeWithAppliedScale, height: sizeWithAppliedScale)
            
            defer {
                resScale *= 0.85
            }
            print("Trying \(sizeWithAppliedScale)x\(sizeWithAppliedScale) with \(resScale) compression")
            
            let resizedIcon = UIGraphicsImageRenderer(size: size).image(actions:{ _ in UIImage(data: rawIcon.jpegData(compressionQuality: resScale)!)!.draw(in: CGRect(origin: .zero, size: size)) })
            
            guard let dummyCatalogURL = Bundle.main.url(forResource: "AssetsDummy\(iconName.count)", withExtension: "car") else { continue }
            let copyURL = fm.temporaryDirectory.appendingPathComponent("AssetsDummy.car")
            try? fm.removeItem(at: copyURL)
            try fm.copyItem(at: dummyCatalogURL, to: copyURL)
            
            let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: copyURL)
            for rendition in renditionsRoot {
                let type = rendition.type
                guard type == .icon else { continue }
                print("type", type)
                if type == .icon {
                    let renditions = rendition.renditions
                    for rend in renditions {
                        rend.cuiRend.unslicedSize()
                        do {
                            try catalog.editItem(rend, fileURL: copyURL, to: .image(resizedIcon.cgImage!))
                        } catch {
                            print("failed to edit rendition: \(error) \(rend.type) \(rend.name) \(rend.namedLookup)")
                        }
                    }
                }
            }
            print(copyURL)
            var byteArray = [UInt8](try Data(contentsOf: copyURL))
            print(byteArray.count)
            guard byteArray.count <= maxSize else { continue } // make sure the bundle can fit
            let findBytes: [UInt8] = [UInt8]("cowabungacowabungacowabunga"[0...iconName.count - 1].data(using: .utf8)!)
            let replaceBytes: [UInt8] = [UInt8](iconName.data(using: .utf8)!)
            
            
            var startIndex = 0
            while startIndex <= byteArray.count - findBytes.count {
                let endIndex = startIndex + findBytes.count
                let subArray = Array(byteArray[startIndex..<endIndex])
                
                if subArray == findBytes {
                    byteArray.replaceSubrange(startIndex..<endIndex, with: replaceBytes)
                    startIndex += replaceBytes.count
                } else {
                    startIndex += 1
                }
            }
            try Data(byteArray).write(to: copyURL)
            
            return copyURL
        }
        
        throw NSLocalizedString("\(bundleIdentifier): Unable to generate an asset catalog with max size \(maxSize)B", comment: "")
    }
    
    static func restoreCatalogs(progress: ((Double,SBApp)) -> Void) throws -> [String] {
        var errors: [String] = []
        let apps = try ApplicationManager.getApps()
        themingInProgress = true
        for (i,app) in apps.enumerated() {
            do {
                try app.restoreCatalog()
                progress(((Double(i) / Double(apps.count)), app))
            } catch {
                if error is MDC.MDCOverwriteError {
                    MDC.isMDCSafe = false
                    throw error.localizedDescription
                } else {
                    errors.append("catalog: \(app.bundleIdentifier) \(app.name) \(error.localizedDescription)")
                }
            }
        }
        themingInProgress = false
        return errors
    }
    static func restoreIconPNGs(progress: ((Double,SBApp)) -> Void) throws -> [String] {
        var errors: [String] = []
        
        let apps = try ApplicationManager.getApps()
        themingInProgress = true
        for (i,app) in apps.enumerated() {
            do {
                try app.restorePNGIcons()
                progress(((Double(i) / Double(apps.count)), app))
            } catch {
                errors.append("png icon: \(app.bundleIdentifier) \(app.name) \(error.localizedDescription)")
            }
        }
        themingInProgress = false
        return errors
    }
    
    
    static func uncorruptCatalogs() throws {
        let apps = try ApplicationManager.getApps()
        themingInProgress = true
        for app in apps {
            let catalogURL = app.bundleURL.appendingPathComponent("Assets.car")
            print(app.bundleIdentifier)
            try? MDC.toggleCatalogCorruption(at: catalogURL.path, corrupt: false)
        }
        themingInProgress = false
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
    
    private func backupCatalog(ofApp app: SBApp) throws {
        let catalogURL = app.bundleURL.appendingPathComponent("Assets.car")
        let destinationURL = app.catalogBackupURL()
        
        guard fm.fileExists(atPath: catalogURL.path) else { return }
        guard !fm.fileExists(atPath: destinationURL.path) else { return }
#warning("might cause issues if icons are bonkers in size")
        let maxSize = 32 * 1024 * 1024
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxSize)
        
        let inputStream = InputStream(url: catalogURL)!
        let outputStream = OutputStream(url: destinationURL, append: false)!
        inputStream.open()
        outputStream.open()
        
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(buffer, maxLength: maxSize)
            if bytesRead > 0 {
                let bytesWritten = outputStream.write(buffer, maxLength: bytesRead)
                if bytesWritten < 0 {
                    break
                }
            } else {
                break
            }
        }
        
        inputStream.close()
        outputStream.close()
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
