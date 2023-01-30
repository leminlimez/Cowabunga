//
//  DownloadableTheme.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import Foundation

class DownloadableTheme {
    var title: String
    var description: String
    var contact: [String: String]
    var previewImageURL: URL
    var downloadURL: URL

    init(title: String, description: String, contact: [String : String], previewImageURL: URL, downloadURL: URL) {
        self.title = title
        self.description = description
        self.contact = contact
        self.previewImageURL = previewImageURL
        self.downloadURL = downloadURL
    }
}
