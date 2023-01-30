//
//  DownloadableTheme.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import Foundation

class DownloadableTheme: Identifiable {
    var name: String
    var description: String
    var contact: [String: String]
    var preview: URL
    var url: URL

    init(name: String, description: String, contact: [String : String], preview: URL, url: URL) {
        self.name = name
        self.description = description
        self.contact = contact
        self.preview = preview
        self.url = url
    }
}
