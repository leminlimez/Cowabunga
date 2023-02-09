//
//  CowabungaAPI.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import UIKit

class CowabungaAPI: ObservableObject {
    
    var serverURL = ""
    var session = URLSession.shared
    
    func fetchPasscodeThemes() async throws -> [DownloadableTheme] {
        var request = URLRequest(url: .init(string: serverURL + "passcode-themes.json")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let themes = try JSONDecoder().decode([DownloadableTheme].self, from: data)
        return themes
    }
    
    func fetchLockThemes() async throws -> [DownloadableTheme] {
        var request = URLRequest(url: .init(string: serverURL + "lock-themes.json")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let themes = try JSONDecoder().decode([DownloadableTheme].self, from: data)
        return themes
    }
    
    func getCommitHash() async throws -> String {
        var request = URLRequest(url: .init(string: serverURL + "https://api.github.com/repos/sourcelocation/Cowabunga-theme-repo/commits/main")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        guard let themes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        guard let hash = themes["sha"] as? String else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        return hash
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
    var url: URL
    var preview: URL
    var contact: [String: String]

    init(name: String, description: String, contact: [String : String], preview: URL, url: URL) {
        self.name = name
        self.description = description
        self.contact = contact
        self.preview = preview
        self.url = url
    }
}
