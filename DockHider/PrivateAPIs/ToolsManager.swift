//
//  ToolsManager.swift
//  DockHider
//
//  Created by lemin on 1/4/23.
//

import UIKit

func respring() {
    guard let window = UIApplication.shared.windows.first else { return }
    while true {
        window.snapshotView(afterScreenUpdates: false)
    }
}

func overwriteFile(isVisible: Bool, typeOfFile: String, isDark: Bool, completion: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
        if typeOfFile == "Dock" {
            let succeeded = overwriteDockWithFileImpl(isVisible: isVisible, isDark: isDark)
            DispatchQueue.main.async {
                completion(succeeded)
            }
        } else if typeOfFile == "HomeBar" {
            let succeeded = overwriteWithFileImpl(originPath: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car", tempName: "/MaterialKit.framework/Assets.car")
            DispatchQueue.main.async {
                completion(succeeded)
            }
        } else if typeOfFile == "FolderBG" {
            let succeededFirst = overwriteWithFileImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderBackground.materialrecipe", tempName: "/SpringBoardHome.framework/folderBackground.materialrecipe")
            let succeededSecond = overwriteWithFileImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe", tempName: "/SpringBoardHome.framework/folderLight.materialrecipe")
            let succeededThird = overwriteWithFileImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedDark.materialrecipe", tempName: "/SpringBoardHome.framework/folderExpandedDark.materialrecipe")
            let succeededFourth = overwriteWithFileImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedLight.materialrecipe", tempName: "/SpringBoardHome.framework/folderExpandedLight.materialrecipe")
            
            let succeeded = succeededFirst && succeededSecond && succeededThird && succeededFourth
            DispatchQueue.main.async {
                completion(succeeded)
            }
        }
    }
}

// Overwrite the dock with the given font using CVE-2022-46689.
// The font must be specially prepared so that it skips past the last byte in every 16KB page.
// Credit to Zhuowei and FontOverwrite for the code logic.
func overwriteDockWithFileImpl(isVisible: Bool, isDark: Bool) -> Bool {
    let CoreMaterialsPath = "/System/Library/PrivateFrameworks/CoreMaterial.framework/"
    let ext = "materialrecipe"
    
    var name: String
    if isDark {
        name = "Dark"
    } else {
        name = "Light"
    }
    
    var urlToDock: URL
    
    if isVisible {
        urlToDock = Bundle.main.url(
            forResource: "default" + name, withExtension: ext)!
    } else {
        urlToDock = Bundle.main.url(
            forResource: "hidden" + name, withExtension: ext)!
    }
    
    let dockData = try! Data(contentsOf: urlToDock)
    
    let originDockPath = CoreMaterialsPath + "dock" + name + "." + ext

    #if false
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ].path
        let originDockPath = documentDirectory + "/dock" + name + "." + ext
        let pathToOriginDock = CoreMaterialsPath + "dock" + name + "." + ext
        let originDockData = try! Data(contentsOf: URL(fileURLWithPath: pathToOriginDock))
        try! originDockData.write(to: URL(fileURLWithPath: originDockPath))
    #endif
    
    // open and map original file
    let file = open(originDockPath, O_RDONLY | O_CLOEXEC)
    if file == -1 {
      print("can't open file?!")
      return false
    }
    defer { close(file) }
    // check size of font
    let originalFileSize = lseek(file, 0, SEEK_END)
    guard originalFileSize >= dockData.count else {
      print("file too big!")
      return false
    }
    lseek(file, 0, SEEK_SET)
    
    // Map the file we want to overwrite so we can mlock it
    let fileMap = mmap(nil, dockData.count, PROT_READ, MAP_SHARED, file, 0)
    if fileMap == MAP_FAILED {
      print("map failed")
      return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, dockData.count) == 0 else {
      print("can't mlock")
      return false
    }

    // for every 16k chunk, rewrite
    for chunkOff in stride(from: 0, to: dockData.count, by: 0x4000) {
      // we only rewrite 16383 bytes out of every 16384 bytes.
      let dataChunk = dockData[chunkOff..<min(dockData.count, chunkOff + 0x3fff)]
      var overwroteOne = false
      for _ in 0..<2 {
        let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
          return unaligned_copy_switch_race(
            file, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
        }
        if overwriteSucceeded {
          overwroteOne = true
          break
        }
        print("try again?!")
        sleep(1)
      }
      guard overwroteOne else {
        print("can't overwrite")
        return false
      }
    }
    print("successfully overwrote everything")
    return true
}

// Overwrite the home bar with the given font using CVE-2022-46689.
// The font must be specially prepared so that it skips past the last byte in every 16KB page.
// Credit to Zhuowei and FontOverwrite for the code logic.
func overwriteWithFileImpl(originPath: String, tempName: String) -> Bool {
    let newData = Data("###".utf8)

    #if false
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ].path
        let originPath = documentDirectory + tempName
        let pathToOrigin = originPath
        let originData = try! Data(contentsOf: URL(fileURLWithPath: pathToOrigin))
        try! originData.write(to: URL(fileURLWithPath: originPath))
    #endif
    
    // open and map original file
    let file = open(originPath, O_RDONLY | O_CLOEXEC)
    if file == -1 {
      print("can't open file?!")
      return false
    }
    defer { close(file) }
    // check size of font
    let originalFileSize = lseek(file, 0, SEEK_END)
    guard originalFileSize >= newData.count else {
      print("file too big!")
      return false
    }
    lseek(file, 0, SEEK_SET)
    
    // Map the file we want to overwrite so we can mlock it
    let fileMap = mmap(nil, newData.count, PROT_READ, MAP_SHARED, file, 0)
    if fileMap == MAP_FAILED {
      print("map failed")
      return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, newData.count) == 0 else {
      print("can't mlock")
      return false
    }

    // for every 16k chunk, rewrite
    for chunkOff in stride(from: 0, to: newData.count, by: 0x4000) {
      // we only rewrite 16383 bytes out of every 16384 bytes.
      let dataChunk = newData[chunkOff..<min(newData.count, chunkOff + 0x3fff)]
      var overwroteOne = false
      for _ in 0..<2 {
        let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
          return unaligned_copy_switch_race(
            file, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
        }
        if overwriteSucceeded {
          overwroteOne = true
          break
        }
        print("try again?!")
        sleep(1)
      }
      guard overwroteOne else {
        print("can't overwrite")
        return false
      }
    }
    print("successfully overwrote everything")
    return true
}
