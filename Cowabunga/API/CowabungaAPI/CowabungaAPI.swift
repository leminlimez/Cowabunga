//
//  CowabungaAPI.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import Foundation

class CowabungaAPI: ObservableObject {
    
    let serverURL = "http://home.sourceloc.net:8080/v1/"
    var session = URLSession.shared
    
    func fetchThemes() async throws -> [DownloadableTheme] {
        var request = URLRequest(url: .init(string: serverURL + "account/login")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
}
