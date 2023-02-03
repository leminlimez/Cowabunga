////
////  ThemeManager.swift
////  TrollTools
////
////  Created by exerhythm on 19.10.2022.
////
//
//import UIKit
//
//var themesDir: URL = {
//#if targetEnvironment(simulator)
//    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-TrollToolsThemes/")
//#else
//    URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-TrollToolsThemes/")
//#endif
//}()
//
//var webclipsActiveIconsDir: URL = {
//#if targetEnvironment(simulator)
//    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ActiveIcons/")
//#else
//    URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-TrollTools/.DO-NOT-DELETE-ActiveIcons/")
//#endif
//}()
//
//class ThemeManager: ObservableObject {
//    let fm = FileManager.default
//    
//    var catalogThemeManager = CatalogThemeManager()
//    var webclipsThemeManager = WebclipsThemeManager()
//    
//    @Published var preferedThemes: [Theme] = []
//    
//    var preferedIcons: [String : ThemedIcon] {
//        get {
//            var res: [String : ThemedIcon] = [:]
//            for theme in preferedThemes {
//                if let icons = try? fm.contentsOfDirectory(at: theme.url, includingPropertiesForKeys: nil) {
//                    for icon in icons {
//                        let appID = appIDFromIcon(url: icon)
//                        res[appID] = .init(appID: appID, themeName: theme.name)
//                    }
//                }
//            }
//            for (overridenAppID, themeName) in iconOverrides {
//                res[overridenAppID] = .init(appID: overridenAppID, themeName: themeName)
//            }
//            return res
//        }
//    }
//    
//    var themes: [Theme] {
//        get { guard let data = UserDefaults.standard.data(forKey: "themes") else { return [] }; return (try? JSONDecoder().decode([Theme].self, from: data)) ?? [] }
//        set { guard let data = try? JSONEncoder().encode(newValue) else { return }; UserDefaults.standard.set(data, forKey: "themes") }
//    }
//    var iconOverrides: [String : String] {
//        get { return UserDefaults.standard.dictionary(forKey: "iconOverrides") as? [String : String] ?? [:] }
//        set { UserDefaults.standard.set(newValue, forKey: "iconOverrides") }
//    }
//    var currentThemedIcons: [ThemedIcon] {
//        get { guard let data = UserDefaults.standard.data(forKey: "currentThemedIcons") else { return [] }; return (try? JSONDecoder().decode([ThemedIcon].self, from: data)) ?? [] }
//        set { guard let data = try? JSONEncoder().encode(newValue) else { return }; UserDefaults.standard.set(data, forKey: "currentThemedIcons") }
//    }
//    
//    // MARK: - Set theme
//    func applyChanges(progress: (String) -> ()) throws {
//        let (userAppChanges, systemAppChanges) = neededChanges()
//        
//        try catalogThemeManager.applyChanges(userAppChanges, progress: { percentage in
////            remLog(str)
//            progress("\(Int(percentage * 100))% done")
//        })
//        try webclipsThemeManager.applyChanges(systemAppChanges, progress: { percentage in
////            remLog(str)
//            progress("\(Int(percentage * 100))% done")
//        })
//    }
//    
//    struct UserAppIconChange {
//        var bundleURL: URL
//        var themeIconURL: URL?
//    }
//    struct SystemAppIconChange {
//        var appID: String
//        var themeIconURL: URL?
//        var localizedName: String
//    }
//    func neededChanges() -> (user: [UserAppIconChange], system: [SystemAppIconChange]) {
//        let apps = LSApplicationWorkspace.default().allApplications() ?? []
//        var userChanges: [UserAppIconChange] = []
//        var systemChanges: [SystemAppIconChange] = []
//        let preferedIcons = preferedIcons
//        
//        for app in apps {
//            let system = app.bundleURL.pathComponents[1] == "Applications"
//            if let themedIcon = preferedIcons[app.applicationIdentifier] {
//                // Icon needs to be themed
//                if system {
//                    systemChanges.append(.init(appID: app.applicationIdentifier, themeIconURL: themedIcon.themeIconURL, localizedName: app.localizedName()))
//                } else {
//                    userChanges.append(.init(bundleURL: app.bundleURL, themeIconURL: themedIcon.themeIconURL))
//                }
//                
//            } else {
//                // Icon needs to be restored
//                if system {
//                    systemChanges.append(.init(appID: app.applicationIdentifier, themeIconURL: nil, localizedName: app.localizedName()))
//                } else {
//                    userChanges.append(.init(bundleURL: app.bundleURL, themeIconURL: nil))
//                }
//            }
//        }
//        return (userChanges, systemChanges)
//    }
//    
//    // MARK: - Getting icons
//    func icons(forAppIDs appIDs: [String], from theme: Theme) throws -> [UIImage?] {
//        appIDs.map { try? icon(forAppID: $0, from: theme) }
//    }
//    func icon(forAppID appID: String, from theme: Theme) throws -> UIImage {
//        guard let image = UIImage(contentsOfFile: theme.url.appendingPathComponent(appID).path + ".png") else { throw "Couldn't open image" }
//        return image
//    }
//    func icon(forAppID appID: String, fromThemeWithName name: String) throws -> UIImage {
//        return try icon(forAppID: appID, from: Theme(name: name, iconCount: 1))
//    }
//    
//    func importTheme(from importURL: URL) throws -> Theme {
//        var name = importURL.deletingPathExtension().lastPathComponent
//        try? fm.createDirectory(at: themesDir, withIntermediateDirectories: true)
//        var themeURL = themesDir.appendingPathComponent(name)
//        
//        if importURL.lastPathComponent.contains(".theme") {
//            for folder in (try? fm.contentsOfDirectory(at: importURL, includingPropertiesForKeys: nil)) ?? [] {
//                if folder.deletingPathExtension().lastPathComponent == "IconBundles" {
//                    themeURL = folder
//                    name = importURL.lastPathComponent.replacingOccurrences(of: ".theme", with: "")
//                }
//            }
//        }
//        
//        try? fm.removeItem(at: themeURL)
//        try fm.createDirectory(at: themeURL, withIntermediateDirectories: true)
//        
//        for icon in (try? fm.contentsOfDirectory(at: importURL, includingPropertiesForKeys: nil)) ?? [] {
//            try? fm.copyItem(at: icon, to: themeURL.appendingPathComponent(appIDFromIcon(url: icon) + ".png"))
//        }
//        return Theme(name: themeURL.deletingPathExtension().lastPathComponent, iconCount: try fm.contentsOfDirectory(at: themeURL, includingPropertiesForKeys: nil).count)
//    }
//    func removeImportedTheme(theme: Theme) throws {
//        try fm.removeItem(at: theme.url)
//    }
//    func removeCurrentThemes(removeWebClips: Bool, progress: (String) -> ()) throws {
//        try catalogThemeManager.restoreCatalogs(progress: progress)
//        try webclipsThemeManager.removeCurrentThemes()
//        if removeWebClips {
//            try webclipsThemeManager.removeWebclips()
//        }
//    }
//    
//    // MARK: - Utils
//    func iconFileEnding(iconFilename: String) -> String {
//        if iconFilename.contains("-large.png") {
//            return "-large"
//        } else if iconFilename.contains("@2x.png") {
//            return"@2x"
//        } else if iconFilename.contains("@23.png") {
//            return "@3x"
//        } else {
//            return ""
//        }
//    }
//    func installedApplicationsNames() throws -> [String: String] {
//        guard let apps = LSApplicationWorkspace.default().allApplications() else { throw "Couldn't get apps" }
//        return apps.reduce(into: [String: String]()) {
//            let applicationIdentifier = $1.applicationIdentifier
//            let displayName = $1.localizedName()
//            $0[applicationIdentifier ?? ""] = displayName
//        }
//    }
//    func appIDFromIcon(url: URL) -> String {
//        return url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: iconFileEnding(iconFilename: url.lastPathComponent), with: "")
//    }
//    func iconURL(appID: String, in theme: Theme) -> URL {
//        return theme.url.appendingPathComponent(appID + ".png")
//    }
//}
//
//
//struct Theme: Codable, Identifiable, Equatable {
//    var id = UUID()
//    
//    var name: String
//    var iconCount: Int
//    var url: URL { // Documents/ImportedThemes/Theme.theme
//        return themesDir.appendingPathComponent(name /*+ ".theme"*/)
//    }
//    
//    static func == (lhs: Theme, rhs: Theme) -> Bool {
//        return lhs.name == rhs.name
//    }
//}
//
//enum IconThemingMethod: String {
//    case webclips, appIcons
//}
//
//struct ThemedIcon: Codable {
//    var appID: String
//    var themeName: String
//    var themeIconURL: URL {
//        themesDir.appendingPathComponent(themeName).appendingPathComponent(appID + ".png")
//    }
//}
