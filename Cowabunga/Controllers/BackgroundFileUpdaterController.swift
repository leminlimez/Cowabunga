//
//  BackgroundFileUpdaterController.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

// credits to sourcelocation and Evyrest

import Foundation
import SwiftUI
import notify
import SystemConfiguration

class BackgroundFileUpdaterController: ObservableObject {
    static let shared = BackgroundFileUpdaterController()
    
    @Published var enabled: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    
    func setup() {
        BackgroundFileUpdaterController.shared.updateFiles()
        Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { timer in
            if self.enabled {
                BackgroundFileUpdaterController.shared.updateFiles()
            }
        }
    }
    
    func stop() {
        // lol
    }
    
    func updateFiles() {
        Task {
            // apply the dock and folder
            // apply the dock
            if UserDefaults.standard.bool(forKey: "DockHidden") == true {
                overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "DockHidden", true) { succceeded in
                    // success
                }
            }
            // apply the folder
            if UserDefaults.standard.bool(forKey: "FolderBGHidden") == true {
                overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "FolderBGHidden", true) { succceeded in
                    // success
                }
            }
        }
    }
}
