//
//  CowabungaAPI.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import Foundation

class CowabungaAPI: ObservableObject {
    
    let serverURL = "https://raw.githubusercontent.com/sourcelocation/Cowabunga-theme-repo/main/"
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
