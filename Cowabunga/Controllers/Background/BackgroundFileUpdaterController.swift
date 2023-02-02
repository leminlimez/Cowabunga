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
    public var time = 120.0
    
    @Published var enabled: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    
    func setup() {
        if self.enabled {
            BackgroundFileUpdaterController.shared.updateFiles()
        }
        Timer.scheduledTimer(withTimeInterval: time, repeats: true) { timer in
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
            // apply the dock
            if UserDefaults.standard.bool(forKey: "DockHidden") == true {
                let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "DockHidden", true)
            } else {
                SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.dock)
            }
            // apply the folder
            if UserDefaults.standard.bool(forKey: "FolderBGHidden") == true {
                let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "FolderBGHidden", true)
            } else {
                SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folder)
            }
            
            // apply the transparent modules
            if UserDefaults.standard.bool(forKey: "CCModuleBackgroundDisabled") == true {
                let _ = overwriteFile(typeOfFile: OverwritingFileTypes.cc, fileIdentifier: "CCModuleBackgroundDisabled", true)
            }
            
            // apply to audios
            let _ = AudioFiles.applyAllAudio()
        }
    }
}
