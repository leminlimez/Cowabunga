//
//  DockTransparencyManager.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import UIKit
import FSOperations

func respring() {
    guard let window = UIApplication.shared.windows.first else { return }
    while true {
        window.snapshotView(afterScreenUpdates: false)
    }
}

func setDockFile(fileName: String, originURL: URL) throws {
    let replacementURL = Bundle.main.url(forResource: fileName, withExtension: "materialrecipe")!
    let replacementData = try! Data(contentsOf: replacementURL)
    
    inProgress = true
    try FSOperation.perform(.writeData(url: originURL, data: replacementData), rootHelperConf: RootConf.shared)
}

func waitUntilFinished() -> Bool {
    var currentTime: Int = Int(Date().timeIntervalSince1970)
    while (true) {
        // this is probably a bad idea but I am stupid :P
        // set a timer until the process is done or it exceeds 30 seconds
        if inProgress == false {
            return true
        } else if currentTime - Int(Date().timeIntervalSince1970) >= 30 {
            return false
        }
    }
}

func applyDock(isVisible: Bool) -> Bool {
    let CoreMaterialsPath = "/System/Library/PrivateFrameworks/CoreMaterial.framework"
    
    let darkPath = CoreMaterialsPath + "/dockDark.materialrecipe"
    let lightPath = CoreMaterialsPath + "/dockLight.materialrecipe"
    
    var darkFile: String
    var lightFile: String
    
    if isVisible {
        darkFile = "defaultDark"
        lightFile = "defaultLight"
    } else {
        darkFile = "hiddenDark"
        lightFile = "hiddenLight"
    }
    
    // apply to the docks
    do {
        // dark
        ApplyingVariables.applyingText = "Applying to dark mode dock..."
        try setDockFile(fileName: darkFile, originURL: URL(string: darkPath)!)
        if !waitUntilFinished() {
            return false
        }
        // light
        ApplyingVariables.applyingText = "Applying to light mode dock..."
        try setDockFile(fileName: lightFile, originURL: URL(string: lightPath)!)
        if !waitUntilFinished() {
            return false
        }
    } catch {
        print("Writing failed")
        return false
    }
    
    // respring
    ApplyingVariables.applyingText = "Respringing..."
    respring()
    
    return true
}
