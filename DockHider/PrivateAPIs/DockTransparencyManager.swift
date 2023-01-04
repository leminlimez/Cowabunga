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
    for _ in 0..<12 {
        if inProgress == false {
            return
        }
        try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
    }
}

func hideHomeBar() {
    inProgress = true
    let originURL = URL(string: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car")!
    let replacementData = Data("###".utf8)
    do {
        try FSOperation.perform(.writeData(url: originURL, data: replacementData), rootHelperConf: RootConf.shared)
    } catch {
        print("AE")
    }
}

func applyTweaks(isVisible: Bool, changesHomeBar: Bool, isLightMode: Bool) -> Bool {
    let CoreMaterialsPath = "/System/Library/PrivateFrameworks/CoreMaterial.framework"
    
    let name: String = isLightMode ? "Light" : "Dark"
    
    let dockPath = CoreMaterialsPath + "/dock" + name + ".materialrecipe"
    
    var dockFile: String
    
    if isVisible {
        dockFile = "default" + name
    } else {
        dockFile = "hidden" + name
    }
    
    // apply to the docks
    do {
        try setDockFile(fileName: dockFile, originURL: URL(string: dockPath)!)
        Task {
            try await waitUntilFinished()
            // apply home bar
            if changesHomeBar {
                hideHomeBar()
                Task {
                    try await waitUntilFinished()
                    // respring
                    respring()
                }
            } else {
                // respring
                respring()
            }
        }
    } catch {
        print("Writing failed")
        return false
    }
    
    return true
}
