//
//  CowabungaAPI.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import UIKit

enum ThemeFilterType: String, CaseIterable {
    case random = "Random"
    case newest = "Newest"
    case oldest = "Oldest"
}

class CowabungaAPI: ObservableObject {
    
    static let shared = CowabungaAPI()
    
    var serverURL = ""
    var session = URLSession.shared
    
    #warning("If we are modifying files, it's no longer an API. Needs refactoring")
    let fm = FileManager.default
    
    func fetchThemes(type: DownloadableTheme.ThemeType) async throws -> [DownloadableTheme] {
        let request = URLRequest(url: .init(string: serverURL + "\(type.rawValue)-themes.json")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let themes = (try JSONDecoder().decode([DownloadableTheme].self, from: data))
        
        for i in themes.indices {
            themes[i].type = type
        }
        
        return themes
    }
    
    func filterTheme(themes: [DownloadableTheme], filterType: ThemeFilterType) -> [DownloadableTheme] {
        var filtered = themes
        if filterType == ThemeFilterType.newest {
            filtered = filtered.reversed()
        } else if filterType == ThemeFilterType.random {
            filtered = filtered.shuffled()
        }
        return filtered
    }
    
    func downloadTheme(theme: DownloadableTheme) async throws {
        let tempThemeDownloadURL = fm.temporaryDirectory.appendingPathComponent("theme.zip")
        try? fm.removeItem(at: tempThemeDownloadURL)
        
        let downloadURL = getDownloadURLForTheme(theme: theme)
        let previewURL = getPreviewURLForTheme(theme: theme)
        
        print("Downloading from \(downloadURL)")
        
        var saveURL = URL.documents
        
        switch theme.type {
        case .passcode:
            saveURL.appendPathComponent("Saved_Passcodes")
        case .lock:
            saveURL.appendPathComponent("Saved_Locks")
        case .icon:
            saveURL = rawThemesDir
        default:
            throw "unknown theme type"
        }
        saveURL.appendPathComponent(theme.name)
        
//        try? FileManager.default.createDirectory(at: saveURL, withIntermediateDirectories: true)
        
        
        let request1 = URLRequest(url: downloadURL)
            
        let (data1,response1) = try await session.data(for: request1) as! (Data, HTTPURLResponse)
        guard response1.statusCode == 200 else { throw "Could not connect to server while downloading theme" }
        try data1.write(to: tempThemeDownloadURL)
        
        switch theme.type {
        case .passcode:
            try? fm.createDirectory(at: saveURL, withIntermediateDirectories: true)
            if fm.fileExists(atPath: saveURL.appendingPathComponent("\(theme.name).passthm").path) {
                try? fm.removeItem(at: saveURL.appendingPathComponent("\(theme.name).passthm"))
            }
            try fm.moveItem(at: tempThemeDownloadURL, to: saveURL.appendingPathComponent("\(theme.name).passthm"))
        case .lock, .icon:
            let tmpExtract = saveURL.deletingLastPathComponent().appendingPathComponent("tmp_extract")
            if FileManager.default.fileExists(atPath: tmpExtract.path) {
                try? FileManager.default.removeItem(at: tmpExtract)
            }
            try fm.unzipItem(at: tempThemeDownloadURL, to: tmpExtract)
            
            if theme.type == .icon {
                try ThemeManager.shared.importTheme(from: tmpExtract.appendingPathComponent(theme.name))
            } else if theme.type == .lock {
                print(saveURL)
                if fm.fileExists(atPath: tmpExtract.appendingPathComponent(theme.name).appendingPathExtension("__MACOSX").path) {
                    try? fm.removeItem(at: tmpExtract.appendingPathComponent(theme.name).appendingPathExtension("__MACOSX"))
                }
                if fm.fileExists(atPath: saveURL.path) {
                    try? fm.removeItem(at: saveURL)
                }
                try fm.moveItem(at: tmpExtract.appendingPathComponent(theme.name.replacingOccurrences(of: " ", with: "_")), to: saveURL)
            }
            
            try fm.removeItem(at: tmpExtract)
        default:
            throw "unknown theme type"
        }
        
        let request2 = URLRequest(url: previewURL)
        let previewSaveURL = saveURL.appendingPathComponent("preview.png")
        let (data2,response2) = try await session.data(for: request2) as! (Data, HTTPURLResponse)
        guard response2.statusCode == 200 else { throw "Could not connect to server while downloading preview" }
        print(previewSaveURL)
        try data2.write(to: previewSaveURL)
        
        try? fm.removeItem(at: tempThemeDownloadURL)
        
        
        //            let saveURL = PasscodeKeyFaceManager.getPasscodesDirectory()!
        //
        //
        //            // save the passthm file
        //            let themeSaveURL = saveURL.appendingPathComponent("theme.passthm")
        //            let themeTask = URLSession.shared.dataTask(with: theme.url) { data, response, error in
        //                guard let data = data else {
        //                    print("No data found!")
        //                    UIApplication.shared.dismissAlert(animated: true)
        //                    UIApplication.shared.alert(title: "Could not download passcode theme!", body: error?.localizedDescription ?? "Unknown Error")
        //                    return
        //                }
        //                do {
        //                    try data.write(to: themeSaveURL)
        //                } catch {
        //                    print("Could not save data to theme save url!")
        //                    UIApplication.shared.dismissAlert(animated: true)
        //                    UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
        //                    return
        //                }
        //
        //                // save the preview file
        //                let previewSaveURL = saveURL.appendingPathComponent("preview.png")
        //                let task = URLSession.shared.dataTask(with: theme.preview) { prevData, prevResponse, prevError in
        //                    guard let prevData = prevData else {
        //                        print("No data found!")
        //                        UIApplication.shared.dismissAlert(animated: true)
        //                        UIApplication.shared.alert(title: "Could not download passcode theme!", body: prevError?.localizedDescription ?? "Unknown Error")
        //                        return
        //                    }
        //                    do {
        //                        try prevData.write(to: previewSaveURL)
        //                        UIApplication.shared.dismissAlert(animated: true)
        //                        UIApplication.shared.alert(title: "Successfully saved passcode theme!", body: "You can use it by tapping the import button in the Passcode Editor and tapping \"Saved\".")
        //                    } catch {
        //                        print("Could not save data to preview url!")
        //                        UIApplication.shared.dismissAlert(animated: true)
        //                        UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
        //                        return
        //                    }
        //                }
        //                task.resume()
        //            }
        //            themeTask.resume()
    }
    
    func getCommitHash() async throws -> String {
        let request = URLRequest(url: .init(string: serverURL + "https://api.github.com/repos/sourcelocation/Cowabunga-theme-repo/commits/main")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        guard let themes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        guard let hash = themes["sha"] as? String else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        return hash
    }
    
    func getDownloadURLForTheme(theme: DownloadableTheme) -> URL {
        URL(string: serverURL + theme.url)!
    }
    
    func getPreviewURLForTheme(theme: DownloadableTheme) -> URL {
        URL(string: serverURL + theme.preview)!
    }
    
    init() {
        Task {
            do {
                let hash = try await getCommitHash()
                serverURL = "https://raw.githubusercontent.com/sourcelocation/Cowabunga-theme-repo/\(hash)/"
            } catch {
                 await UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    }
}

class DownloadableTheme: Identifiable, Codable {
    var name: String
    var description: String
    var url: String
    var preview: String
    var contact: [String: String]
    var type: ThemeType?
    var version: String

    init(name: String, description: String, contact: [String : String], preview: String, url: String, version: String) {
        self.name = name
        self.description = description
        self.contact = contact
        self.preview = preview
        self.url = url
        self.version = version
    }
    
    enum ThemeType: String, Codable {
        case passcode, lock, icon
    }
}
