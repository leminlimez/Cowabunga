//
//  ToolsManager.swift
//  Cowabunga
//
//  Created by lemin on 1/4/23.
//

import UIKit

// get the user defaults for a boolean key
func getDefaultBool(forKey: String, defaultValue: Bool = false) -> Bool {
    let defaults = UserDefaults.standard
    
    return defaults.object(forKey: forKey) as? Bool ?? defaultValue
}

// set a user defaults value for a boolean key
func setDefaultBoolean(forKey: String, value: Bool) {
    let defaults = UserDefaults.standard
    
    defaults.set(value, forKey: forKey)
}

func respring() {
    guard let window = UIApplication.shared.windows.first else { return }
    while true {
        window.snapshotView(afterScreenUpdates: false)
    }
}

let replacementPaths: [String: [String]] = [
    "DockHidden": ["CoreMaterial.framework/dockDark.materialrecipe", "CoreMaterial.framework/dockLight.materialrecipe"],
    "HomeBarHidden": ["MaterialKit.framework/Assets.car"],
    "FolderBGHidden": ["SpringBoardHome.framework/folderLight.materialrecipe", "SpringBoardHome.framework/folderDark.materialrecipe", "SpringBoardHome.framework/folderDarkSimplified.materialrecipe"],
    "FolderBlurDisabled": ["SpringBoardHome.framework/folderExpandedBackgroundHome.materialrecipe", "SpringBoardHome.framework/folderExpandedBackgroundHomeSimplified.materialrecipe"],
    "SwitcherBlurDisabled": ["SpringBoard.framework/homeScreenBackdrop-application.materialrecipe", "SpringBoard.framework/homeScreenBackdrop-switcher.materialrecipe"],
    "ShortcutBannerDisabled": ["SpringBoard.framework/BannersAuthorizedBundleIDs.plist"],
]

enum OverwritingFileTypes {
    case springboard
    case plist
    case audio
    case region
}

func overwriteFile<Value>(typeOfFile: OverwritingFileTypes, fileIdentifier: String, _ value: Value, completion: @escaping (Bool) -> Void) {
    // find the path and replace the file
    // springboard option
    if typeOfFile == OverwritingFileTypes.springboard {
        // springboard tweak being applied
        if replacementPaths[fileIdentifier] != nil {
            var succeeded = true
            for path in replacementPaths[fileIdentifier]! {
                do {
                    let originalData = try Data(contentsOf: URL(fileURLWithPath: "/System/Library/PrivateFrameworks/" + path))
                    let randomGarbage = Data(String.init(repeating: "#", count: originalData.count).utf8)
                    DispatchQueue.global(qos: .userInteractive).async {
                        //overwriteFile(randomGarbage, "/System/Library/PrivateFrameworks/"+path)
                        succeeded = succeeded && overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/" + path, backupName: path, replacementData: randomGarbage)
                    }
                } catch {
                    print("Could not get data")
                    succeeded = false
                }
            }
            DispatchQueue.main.async {
                completion(succeeded)
            }
        }
    
    // audio option
    } else if typeOfFile == OverwritingFileTypes.audio {
        let path = AudioFiles.getAudioPath(attachment: fileIdentifier)
        if path != nil {
            // replace the audio data
            let base64 = AudioFiles.getNewAudioData(soundName: value as! String)
            if base64 != nil {
                let newData = Data(base64Encoded: base64!)!
                let succeeded = overwriteFileWithDataImpl(originPath: "/System/Library/Audio/" + path!, backupName: path!, replacementData: newData)
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            } else if let customAudioData = AudioFiles.getCustomAudioData(soundName: value as! String) {
                let succeeded = overwriteFileWithDataImpl(originPath: "/System/Library/Audio/" + path!, backupName: path!, replacementData: customAudioData)
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    
    } else if typeOfFile == OverwritingFileTypes.plist {
        if replacementPaths[fileIdentifier] != nil {
            let path: String = replacementPaths[fileIdentifier]![0]
            let plistData = try! Data(contentsOf: URL(fileURLWithPath: "/System/Library/PrivateFrameworks/" + path))
            let plist = try! PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String]
            
            var newPlist = plist
            // nullify the file
            for (i, v) in plist.enumerated() {
                newPlist[i] = String(repeating: "#", count: v.count)
            }
            
            // overwrite the plist
            let newData = try! PropertyListSerialization.data(fromPropertyList: newPlist, format: .binary, options: 0)
            
            let succeeded = overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/" + path, backupName: path, replacementData: newData)
            DispatchQueue.main.async {
                completion(succeeded)
            }
        }
    } else if typeOfFile == OverwritingFileTypes.region {
        let startPath = "/Library/RegionFeatures/RegionFeatures_"
        let devices = ["iphone", "audio"]
        var succeeded = true
        
        for dev in devices {
            let newData: Data = Data(base64Encoded: regionEncodes[dev]!)!
            succeeded = succeeded && overwriteFileWithDataImpl(originPath: startPath + dev + ".txt", backupName: "RegionFeatures_"+dev+".txt", replacementData: newData)
        }
        DispatchQueue.main.async {
            completion(succeeded)
        }
    }
}

// Overwrite the system font with the given font using CVE-2022-46689.
// The font must be specially prepared so that it skips past the last byte in every 16KB page.
// See BrotliPadding.swift for an implementation that adds this padding to WOFF2 fonts.
// credit: FontOverwrite
func overwriteFileWithDataImpl(originPath: String, backupName: String, replacementData: Data) -> Bool {
#if false
    let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].path
    
    let pathToRealTarget = originPath
    let originPath = documentDirectory + backupName
    let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
    try! origData.write(to: URL(fileURLWithPath: originPath))
#endif
    
    // open and map original font
    let fd = open(originPath, O_RDONLY | O_CLOEXEC)
    if fd == -1 {
        print("Could not open target file")
        return false
    }
    defer { close(fd) }
    // check size of font
    let originalFileSize = lseek(fd, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
        print("File too big")
        return false
    }
    lseek(fd, 0, SEEK_SET)
    
    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
    if fileMap == MAP_FAILED {
        print("Failed to map")
        return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
        print("Failed to mlock")
        return true
    }
    
    // for every 16k chunk, rewrite
    print(Date())
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
        print(String(format: "%lx", chunkOff))
        let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
        var overwroteOne = false
        for _ in 0..<2 {
            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                return unaligned_copy_switch_race(
                    fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
            }
            if overwriteSucceeded {
                overwroteOne = true
                break
            }
            print("try again?!")
        }
        guard overwroteOne else {
            print("Failed to overwrite")
            return false
        }
    }
    print(Date())
    return true
}
