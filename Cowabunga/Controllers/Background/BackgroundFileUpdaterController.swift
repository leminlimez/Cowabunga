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

struct BackgroundOption: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var enabled: Bool = true
}

class BackgroundFileUpdaterController: ObservableObject {
    static let shared = BackgroundFileUpdaterController()
    
    public var BackgroundOptions: [BackgroundOption] = [
        .init(key: "Dock", title: NSLocalizedString("Dock", comment: "Run in background option")),
        .init(key: "HomeBar", title: NSLocalizedString("Home Bar", comment: "Run in background option")),
        .init(key: "FolderBG", title: NSLocalizedString("Folder Background", comment: "Run in background option")),
        .init(key: "FolderBlur", title: NSLocalizedString("Folder Blur", comment: "Run in background option")),
        .init(key: "PodBackground", title: NSLocalizedString("Library Pod Backgrounds", comment: "Run in background option")),
        .init(key: "NotifBackground", title: NSLocalizedString("Notification Banner Background", comment: "Run in background option")),
        .init(key: "CCBG", title: NSLocalizedString("CC Background Blur", comment: "Run in background option")),
        .init(key: "CCModuleBackground", title: NSLocalizedString("CC Module Background", comment: "Run in background option")),
        .init(key: "Lock", title: NSLocalizedString("Lock", comment: "Run in background option")),
        .init(key: "Audio", title: NSLocalizedString("Audio", comment: "Run in background option")),
        .init(key: "SettingsCustomizer", title: NSLocalizedString("Settings Customizations", comment: "Run in background option"))
    ]
    
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
            if themingInProgress { return }
            let ak: String = "_BGApply"
            
            // apply the dock
            if UserDefaults.standard.bool(forKey: "Dock\(ak)") {
                if UserDefaults.standard.string(forKey: "Dock") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.dock)
                }
            }
            // apply the home bar
            if UserDefaults.standard.bool(forKey: "HomeBar\(ak)") {
                if UserDefaults.standard.string(forKey: "HomeBar") == "Disabled" {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "HomeBarHidden", true)
                }
            }
            // apply the folder bg
            if UserDefaults.standard.bool(forKey: "FolderBG\(ak)") {
                if UserDefaults.standard.string(forKey: "FolderBG") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folder)
                }
            }
            // apply the folder blur
            if UserDefaults.standard.bool(forKey: "FolderBlur\(ak)") {
                if UserDefaults.standard.string(forKey: "FolderBlur") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folderBG)
                }
            }
            // apply the app library pods
            if UserDefaults.standard.bool(forKey: "PodBackground\(ak)") {
                if UserDefaults.standard.string(forKey: "PodBG") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.libraryFolder)
                }
            }
            // apply the notif banner
            if UserDefaults.standard.bool(forKey: "NotifBackground\(ak)") {
                if UserDefaults.standard.string(forKey: "NotifBG") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.notif)
                }
            }
            // apply the notif shadow
            if UserDefaults.standard.bool(forKey: "NotifBackground\(ak)") {
                if UserDefaults.standard.string(forKey: "NotifShadow") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.notifShadow)
                }
            }
            // apply the cc bg blur
            if UserDefaults.standard.bool(forKey: "CCBG\(ak)") {
                if UserDefaults.standard.string(forKey: "CCBG") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: .moduleBG)
                }
            }
            // apply the transparent modules
            if UserDefaults.standard.bool(forKey: "CCModuleBackground\(ak)") {
                if UserDefaults.standard.string(forKey: "CCModuleBG") ?? "Visible" != "Visible" {
                    SpringboardColorManager.applyColor(forType: .module)
                }
            }
            
            // apply lock
            if UserDefaults.standard.bool(forKey: "Lock\(ak)") {
                if UserDefaults.standard.string(forKey: "CurrentLock") ?? "Default" != "Default" {
                    let lockName: String = UserDefaults.standard.string(forKey: "CurrentLock")!
                    print("applying lock")
                    let _ = LockManager.applyLock(lockName: lockName)
                }
            }
            
            // apply the settings tweak
            if UserDefaults.standard.bool(forKey: "SettingsCustomizer\(ak)") {
                do {
                    try SettingsCustomizerManager.apply()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            // apply custom operations
            do {
                try AdvancedManager.applyOperations(background: true)
            } catch {
                print(error.localizedDescription)
            }
            
            // apply to audios
            if UserDefaults.standard.bool(forKey: "Audio\(ak)") {
                let _ = AudioFiles.applyAllAudio()
            }
            
            // kill screentime agent
            if UserDefaults.standard.bool(forKey: "stakillerenabled") == true {
                killSTA()
            }
        }
    }
}
