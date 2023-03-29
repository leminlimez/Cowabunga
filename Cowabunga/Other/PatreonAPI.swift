//
//  PatreonAPI.swift
//  Cowabunga
//
//  Created by lemin on 2/24/23.
//

import UIKit

class PatreonAPI: ObservableObject {
    static let shared = PatreonAPI()
    
    var serverURL = ""
    var session = URLSession.shared
    
    let fm = FileManager.default
    
    func fetchPatrons() async throws -> [Patron] {
        let request = URLRequest(url: .init(string: serverURL + "patrons.json")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let patrons = (try JSONDecoder().decode([Patron].self, from: data))
        
        return patrons
    }
    
    func getCommitHash() async throws -> String {
        let request = URLRequest(url: .init(string: serverURL + "https://api.github.com/repos/leminlimez/Cowabunga-explore-repo/commits/main")!)
        
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
                serverURL = "https://raw.githubusercontent.com/leminlimez/Cowabunga-explore-repo/\(hash)/"
            } catch {
                 await UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    }
}

class Patron: Identifiable, Codable {
    var name: String

    init(name: String) {
        self.name = name
    }
}
