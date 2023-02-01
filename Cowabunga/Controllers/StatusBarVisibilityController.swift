//
//  HiderFuncs.swift
//  VanishBar
//
//  Created by Анохин Юрий on 30.01.2023.
//

import Foundation

class StatusBarVisibilityController {
    static var shared = StatusBarVisibilityController()
    
    enum StatusBarHider {
        case
    }
    
    let fm = FileManager.default
    
    func changeStatusBarVisibility(hidden: Bool, versionOS: String) throws {
        let overrideFile = Bundle.main.url(forResource: "statusBarOverrides\(versionOS)", withExtension: nil)
        
        if hidden {
            try fm.createFile(atPath: "/var/mobile/Library/SpringBoard/statusBarOverrides", contents: Data(contentsOf: overrideFile!))
        } else {
            try fm.removeItem(atPath: "/var/mobile/Library/SpringBoard/statusBarOverrides")
        }
    }
    
    func isApplied() -> Bool {
        return fm.fileExists(atPath: "/var/mobile/Library/SpringBoard/statusBarOverrides")
    }
}
