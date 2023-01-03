//
//  DockTransparencyManager.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import UIKit

func overwriteDock(isVisible: Bool, completion: @escaping (String) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
        let succeeded = overwriteDockImpl(isVisible: isVisible)
        DispatchQueue.main.async {
            completion(succeeded ? "Success" : "Failed")
        }
    }
}

// Overwrite the dock file with the given font using CVE-2022-46689.
// The font must be specially prepared so that it skips past the last byte in every 16KB page.
// Credit to Zhuowei's FontOverwrite for code logic
func overwriteDockImpl(isVisible: Bool) -> Bool {
    let darkName = "dockDark.materialrecipe"
    let lightName = "dockLight.materialrecipe"
    let CoreMaterialsPath = "/System/Library/PrivateFrameworks/CoreMaterial.framework"
    let darkPath = CoreMaterialsPath + "/" + darkName
    let lightPath = CoreMaterialsPath + "/" + lightName
    
    var dockDarkURL: URL
    var dockLightURL: URL
    if isVisible {
        // default dock files
        dockDarkURL = Bundle.main.url(
            forResource: darkName, withExtension: nil, subdirectory: "DefaultDock")!
        dockLightURL = Bundle.main.url(
            forResource: lightName, withExtension: nil, subdirectory: "DefaultDock")!
    } else {
        // transparent dock files
        dockDarkURL = Bundle.main.url(
            forResource: darkName, withExtension: nil, subdirectory: "HiddenDock")!
        dockLightURL = Bundle.main.url(
            forResource: lightName, withExtension: nil, subdirectory: "HiddenDock")!
    }
    
    var dockDarkData = try! Data(contentsOf: dockDarkURL)
    var dockLightData = try! Data(contentsOf: dockLightURL)
    
    #if false
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ].path
        let darkPath = documentDirectory + "/" + darkName
        let lightPath = documentDirectory + "/" + lightName
        let realDarkPath = CoreMaterialsPath + "/" + darkName
        let realLightPath = CoreMaterialsPath + "/" + lightName
        let origDarkData = try! Data(contentsOf: URL(fileURLWithPath: realDarkPath))
        let origLightData = try! Data(contentsOf: URL(fileURLWithPath: realLightPath))
        try! origDarkData.write(to: URL(fileURLWithPath: realDarkPath))
        try! origLightData.write(to: URL(fileURLWithPath: realLightPath))
    #endif
    
    let file = open(darkPath, O_RDONLY | O_CLOEXEC)
    if file == -1 {
      print("can't open file?!")
      return false
    }
    defer { close(file) }
    // check size of the file
    let originalFileSize = lseek(file, 0, SEEK_END)
    guard originalFileSize >= dockDarkData.count else {
      print("file too big!")
      return false
    }
    lseek(file, 0, SEEK_SET)
    
    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, dockDarkData.count, PROT_READ, MAP_SHARED, file, 0)
    if fileMap == MAP_FAILED {
      print("map failed")
      return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, dockDarkData.count) == 0 else {
      print("can't mlock")
      return false
    }

    // for every 16k chunk, rewrite
    for chunkOff in stride(from: 0, to: dockDarkData.count, by: 0x4000) {
      // we only rewrite 16383 bytes out of every 16384 bytes.
      let dataChunk = dockDarkData[chunkOff..<min(dockDarkData.count, chunkOff + 0x3fff)]
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
