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
        let randomGarbage = Data("###".utf8)
        
        // DOCK
        if typeOfFile == "Dock" {
            if isVisible {
                // make dock visible
                // dark
                let succeeded1 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", backupName: "dockDark.materialrecipe", replacementData: try! Data(contentsOf:  Bundle.main.url(forResource: "defaultDark", withExtension: "materialrecipe")!))
                // light
                let succeeded2 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe", backupName: "dockLight.materialrecipe", replacementData: try! Data(contentsOf:  Bundle.main.url(forResource: "defaultLight", withExtension: "materialrecipe")!))
                let succeeded = succeeded1 && succeeded2
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            } else {
                // make dock hidden
                let succeeded1 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", backupName: "dockDark.materialrecipe", replacementData: try! Data(contentsOf:  Bundle.main.url(forResource: "hiddenDark", withExtension: "materialrecipe")!))
                // light
                let succeeded2 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe", backupName: "dockLight.materialrecipe", replacementData: try! Data(contentsOf:  Bundle.main.url(forResource: "hiddenLight", withExtension: "materialrecipe")!))
                let succeeded = succeeded1 && succeeded2
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            }
        
        // HOME BAR
        } else if typeOfFile == "HomeBar" {
            let succeeded = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car", backupName: "/MaterialKit.framework/Assets.car", replacementData: randomGarbage)
            DispatchQueue.main.async {
                completion(succeeded)
            }
        
        // FOLDER BG
        } else if typeOfFile == "FolderBG" {
            let succeeded1 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe", backupName: "/SpringBoardHome.framework/folderLight.materialrecipe", replacementData: randomGarbage)
            let succeeded2 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe", backupName: "/SpringBoardHome.framework/folderDark.materialrecipe", replacementData: randomGarbage)
            let succeeded3 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDarkSimplified.materialrecipe", backupName: "/SpringBoardHome.framework/folderDarkSimplified.materialrecipe", replacementData: randomGarbage)
            
            let succeeded = succeeded1 && succeeded2 && succeeded3
            DispatchQueue.main.async {
                completion(succeeded)
            }
        
        // FOLDER BLUR
        } else if typeOfFile == "FolderBlur" {
            let succeeded1 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedBackgroundHome.materialrecipe", backupName: "/SpringBoardHome.framework/folderExpandedBackgroundHome.materialrecipe", replacementData: randomGarbage)
            let succeeded2 = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderExpandedBackgroundHomeSimplified.materialrecipe", backupName: "/SpringBoardHome.framework/folderExpandedBackgroundHomeSimplified.materialrecipe", replacementData: randomGarbage)
        }
    }
}

// Overwrite the dock with the given font using CVE-2022-46689.
// The font must be specially prepared so that it skips past the last byte in every 16KB page.
// Credit to Zhuowei and FontOverwrite for the code logic.
func overwriteFileWithDataImpl(originPath: String, backupName: String, replacementData: Data) -> Bool {
    let originFilePath = originPath
    
    #if false
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ].path
        let originFilePath = documentDirectory + backupName
        let pathToOriginFile = originPath
        let originFileData = try! Data(contentsOf: URL(fileURLWithPath: pathToOriginFile))
        try! originFileData.write(to: URL(fileURLWithPath: originFilePath))
    #endif
    
    // open and map original file
    let file = open(originFilePath, O_RDONLY | O_CLOEXEC)
    if file == -1 {
      print("can't open file?!")
      return false
    }
    defer { close(file) }
    // check size of file
    let originalFileSize = lseek(file, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
      print("file too big!")
      return false
    }
    lseek(file, 0, SEEK_SET)
    
    // Map the file we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, file, 0)
    if fileMap == MAP_FAILED {
      print("map failed")
      return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
      print("can't mlock")
      return false
    }

    // for every 16k chunk, rewrite
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
      // we only rewrite 16383 bytes out of every 16384 bytes.
      let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x3fff)]
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
