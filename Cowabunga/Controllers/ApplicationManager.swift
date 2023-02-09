//
//  ApplicationManager.swift
//  Cowabunga
//
//  Created by sourcelocation on 03/02/2023.
//

import UIKit


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
            
            var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, pngIconPaths: [])
            
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { throw "Error reading display name for \(bundleUrl.absoluteString)" }
                app.name = CFBundleDisplayName
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { throw "Error reading name for \(bundleUrl.absoluteString)" }
                app.name = CFBundleName
            }
            
            // obtaining png icons inside bundle. defined in info.plist
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String : AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png"}
                    }
                }
            }
            
            
            apps.append(app)
        }
        
        return apps
    }
}

struct SBApp {
    var bundleIdentifier: String
    var name: String
    var bundleURL: URL
    
    var pngIconPaths: [String]
    
    func originalIconURL(fileName: String) -> URL {
        originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + fileName)
    }
}
