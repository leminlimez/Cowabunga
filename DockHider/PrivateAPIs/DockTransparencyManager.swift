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

func setDockFile(fileName: String, replacePath: String) {
    
}

func applyDock(isVisible: Bool) -> Bool {
    let CoreMaterialsPath = "/System/Library/PrivateFrameworks/CoreMaterial.framework"
    
    let darkName = "dockDark.materialrecipe"
    let darkPath = CoreMaterialsPath + "/" + darkName
    var darkURL = URL(string: darkPath)!
    let dockDarkURL = Bundle.main.url(forResource: "dockDark", withExtension: "materialrecipe")!
    let dockDarkData = try! Data(contentsOf: dockDarkURL)//: Data
    
    /*if isVisible {
        dockDarkData = try! Data(contentsOf: Bundle.main.url(
            forResource: "dockDark2.materialrecipe", withExtension: nil, subdirectory: "DefaultDocks")!)
    } else {
        dockDarkData = try! Data(contentsOf: Bundle.main.url(
            forResource: darkName, withExtension: nil, subdirectory: "HiddenDocks")!)
    }*/
    
    do {
        try FSOperation.perform(.writeData(url: darkURL, data: dockDarkData), rootHelperConf: RootConf.shared)
    } catch {
        return false
    }
    return true
}
