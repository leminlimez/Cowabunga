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

func waitUntilFinished() async throws -> Void {
    for _ in 0..<20 {
        if inProgress == false {
            return
        }
        try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
    }
}

func applyDock(isVisible: Bool) -> Bool {
    let CoreMaterialsPath = "/System/Library/PrivateFrameworks/CoreMaterial.framework"
    
    let darkPath = CoreMaterialsPath + "/dockDark.materialrecipe"
    let lightPath = CoreMaterialsPath + "/dockLight.materialrecipe"
    
    var darkFile: String
    
    if isVisible {
        darkFile = "defaultDark"
    } else {
        darkFile = "hiddenDark"
    }
    
    // apply to the docks
    do {
        // dark
        ApplyingVariables.applyingText = "Applying dock files..."
        try setDockFile(fileName: darkFile, originURL: URL(string: darkPath)!)
        Task {
            try await waitUntilFinished()
            if !noDiff {
                // light
                ApplyingVariables.applyingText = "Applying dock files..."
                
                var lightFile: String
                if isVisible {
                    lightFile = "defaultLight"
                } else {
                    lightFile = "hiddenLight"
                }
                
                try setDockFile(fileName: lightFile, originURL: URL(string: lightPath)!)
                Task {
                    try await waitUntilFinished()
                    // respring
                    ApplyingVariables.applyingText = "Respringing..."
                    respring()
                }
            } else {
                if isVisible {
                    ApplyingVariables.applyingText = "Dock is already visible!"
                } else {
                    ApplyingVariables.applyingText = "Dock is already hidden!"
                }
            }
        }
    } catch {
        print("Writing failed")
        return false
    }
    
    return true
}
