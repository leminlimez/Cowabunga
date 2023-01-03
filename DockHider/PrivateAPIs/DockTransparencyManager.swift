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
    
    try FSOperation.perform(.writeData(url: originURL, data: replacementData), rootHelperConf: RootConf.shared)
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
        try setDockFile(fileName: darkFile, originURL: URL(string: darkPath)!)
        // light
        try setDockFile(fileName: lightFile, originURL: URL(string: lightPath)!)
    } catch {
        return false
    }
    
    // respring
    respring()
    
    return true
}
