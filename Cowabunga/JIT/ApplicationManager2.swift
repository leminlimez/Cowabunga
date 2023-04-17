//
//  ApplicationManager.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import UIKit

// does nothing lololo
enum GenericError: Error {
    case runtimeError(String)
}

// stolen from appabetical :trolley:
class ApplicationManager2 {
    private static var fm = FileManager.default
    static var shared = ApplicationManager2()

    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    static func getApps() throws -> [SBApp2] {
        var dotAppDirs: [URL] = []

        let userAppsDir = try fm.contentsOfDirectory(at: userApplicationsUrl, includingPropertiesForKeys: nil)
        
        for userAppFolder in userAppsDir {
            let userAppFolderContents = try fm.contentsOfDirectory(at: userAppFolder, includingPropertiesForKeys: nil)
            if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
                dotAppDirs.append(dotApp)
            }
        }
        
        var apps2: [SBApp2] = []
        
        for bundleUrl in dotAppDirs {
            let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
            if !fm.fileExists(atPath: infoPlistUrl.path) {
                // some system apps don't have it, just ignore it and move on.
                continue
            }
            
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { UIApplication.shared.alert(title: "Error", body: "Error opening info.plist for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error opening info.plist for \(bundleUrl.absoluteString)") }
            guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(title: "Error", body: "App \(bundleUrl.absoluteString) doesn't have bundleid"); throw GenericError.runtimeError("App \(bundleUrl.absoluteString) doesn't have bundleid")}
            
            var app2 = SBApp2(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, pngIconPaths: [], hiddenFromSpringboard: false)
            
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { UIApplication.shared.alert(title: "Error", body: "Error reading display name for \(bundleUrl.absoluteString)"); throw GenericError.runtimeError("Error reading display name for \(bundleUrl.absoluteString)") }
                app2.name = CFBundleDisplayName
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { UIApplication.shared.alert(title: "Error", body: "Error reading name for \(bundleUrl.absoluteString)");throw GenericError.runtimeError("Error reading name for \(bundleUrl.absoluteString)")}
                app2.name = CFBundleName
            }
            
            // obtaining png icons inside bundle. defined in info.plist
            if app2.bundleIdentifier == "com.apple.mobiletimer" {
                // use correct paths for clock, because it has arrows
                app2.pngIconPaths += ["circle_borderless@2x~iphone.png"]
            }
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String : AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app2.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png"}
                    }
                }
            }
            if infoPlist.keys.contains("CFBundleIconFile") {
                // happens in the case of pseudo-installed apps
                if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                    app2.pngIconPaths.append(CFBundleIconFile + ".png")
                }
            }
            if infoPlist.keys.contains("CFBundleIconFiles") {
                // only seen this happen in the case of Wallet
                if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                    app2.pngIconPaths += CFBundleIconFiles.map { $0 + ".png" }
                }
            }
            
            
            apps2.append(app2)
        }
        
        return apps2
    }
    
    func openApp(_ BundleID: String) {
        guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
        let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
        workspace?.perform(Selector(("openApplicationWithBundleID:")), with: BundleID)
    }
}

struct SBApp2: Identifiable, Equatable {
    var id = UUID()
    var bundleIdentifier: String
    var name: String
    var bundleURL: URL
    
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
}
