//
//  Extensions.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import Foundation

extension URL {
    static var documents: URL {
        return FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
//
//extension String: LocalizedError {
//    public var errorDescription: String? { return self }
//}
