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

enum SpringBoardOptions: String, CaseIterable {
    case DockHidden = "DockHidden"
    case HomeBarHidden = "HomeBarHidden"
    case FolderBGHidden = "FolderBGHidden"
    case FolderBlurDisabled = "FolderBlurDisabled"
    case SwitcherBlurDisabled = "SwitcherBlurDisabled"
    case ShortcutBannerDisabled = "ShortcutBannerDisabled"
}

let replacementPaths: [String: [String]] = [
    SpringBoardOptions.DockHidden.rawValue: ["CoreMaterial.framework/dockDark.materialrecipe", "CoreMaterial.framework/dockLight.materialrecipe"],
    SpringBoardOptions.HomeBarHidden.rawValue: ["MaterialKit.framework/Assets.car"],
    SpringBoardOptions.FolderBGHidden.rawValue: ["SpringBoardHome.framework/folderLight.materialrecipe", "SpringBoardHome.framework/folderDark.materialrecipe", "SpringBoardHome.framework/folderDarkSimplified.materialrecipe"],
    SpringBoardOptions.FolderBlurDisabled.rawValue: ["SpringBoardHome.framework/folderExpandedBackgroundHome.materialrecipe", "SpringBoardHome.framework/folderExpandedBackgroundHomeSimplified.materialrecipe"],
    SpringBoardOptions.SwitcherBlurDisabled.rawValue: ["SpringBoard.framework/homeScreenBackdrop-application.materialrecipe", "SpringBoard.framework/homeScreenBackdrop-switcher.materialrecipe"],
    SpringBoardOptions.ShortcutBannerDisabled.rawValue: ["SpringBoard.framework/BannersAuthorizedBundleIDs.plist"],
]

enum OverwritingFileTypes {
    case springboard
    case plist
    case audio
    case region
}

// reset the device subtype
func resetDeviceSubType() -> Bool {
    var canUseStandardMethod: [String] = ["10,3", "10,4", "10,6", "11,2", "11,4", "11,6", "11,8", "12,1", "12,3", "12,5", "13,1", "13,2", "13,3", "13,4", "14,4", "14,5", "14,2", "14,3", "14,7", "14,8", "15,2"]
    for (i, v) in canUseStandardMethod.enumerated() {
        canUseStandardMethod[i] = "iPhone" + v
    }
    
    var deviceSubType: Int = -1
    let deviceModel: String = UIDevice().machineName

    print("Device Model: " + deviceModel)
    if canUseStandardMethod.contains(deviceModel) {
        // can use device bounds
        deviceSubType = Int(UIScreen.main.nativeBounds.height)
    } else {//else if specialCases[deviceModel] != nil {
        //deviceSubType = specialCases[deviceModel]!
        let url: URL? = URL(string: "https://raw.githubusercontent.com/leminlimez/Cowabunga/main/DefaultSubTypes.json")
        if url != nil {
            // get the data of the file
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data else {
                    print("No data to decode")
                    return
                }
                guard let subtypeData = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    print("Couldn't decode json data")
                    return
                }
                
                // check if all the files exist
                if  let subtypeData = subtypeData as? Dictionary<String, AnyObject>, let deviceTypes = subtypeData["Default_SubTypes"] as? [String: Int] {
                    if deviceTypes[deviceModel] != nil {
                        // successfully found subtype
                        deviceSubType = deviceTypes[deviceModel] ?? -1
                    }
                }
            }
            task.resume()
        }
    }
    
    // set the subtype
    print("Device SubType: " + String(deviceSubType))
    if deviceSubType > 0 {
        UserDefaults.standard.set(deviceSubType, forKey: "OriginalDeviceSubType")
        return true
    } else {
        print("Could not get the device subtype")
    }
    return false
    }

func overwriteFile<Value>(typeOfFile: OverwritingFileTypes, fileIdentifier: String, _ value: Value) -> Bool {
    // find the path and replace the file
    // springboard option
    if typeOfFile == OverwritingFileTypes.springboard {
        // springboard tweak being applied
        if replacementPaths[fileIdentifier] != nil {
            var succeeded = true
            for path in replacementPaths[fileIdentifier]! {
                let randomGarbage = Data("###".utf8)
                succeeded = succeeded && overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/" + path, replacementData: randomGarbage)
            }
            return succeeded
        }
    
    // audio option
    } else if typeOfFile == OverwritingFileTypes.audio {
        let path = AudioFiles.getAudioPath(attachment: fileIdentifier)
        if path != nil {
            if value as! String == "Off" {
                // disable the audio
                let randomGarbage = Data("###".utf8)
                return overwriteFileWithDataImpl(originPath: "/System/Library/Audio/" + path!, replacementData: randomGarbage)
            } else {
                // replace the audio data
                let newData = AudioFiles.getNewAudioData(soundName: value as! String)
                if newData != nil {
                    return overwriteFileWithDataImpl(originPath: "/System/Library/Audio/" + path!, replacementData: newData!)
                } else if let customAudioData = AudioFiles.getCustomAudioData(soundName: value as! String) {
                    return overwriteFileWithDataImpl(originPath: "/System/Library/Audio/" + path!, replacementData: customAudioData)
                }
            }
        }
    
    // modifying a plist
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
            
            return overwriteFileWithDataImpl(originPath: "/System/Library/PrivateFrameworks/" + path, replacementData: newData)
        }
    } else if typeOfFile == OverwritingFileTypes.region {
        let startPath = "/Library/RegionFeatures/RegionFeatures_"
        let devices = ["iphone", "audio"]
        var succeeded = true
        
        for dev in devices {
            let newData: Data = Data(base64Encoded: regionEncodes[dev]!)!
            succeeded = succeeded && overwriteFileWithDataImpl(originPath: startPath + dev + ".txt", replacementData: newData)
        }
        return succeeded
    }
    return false
}

// Overwrite the system font with the given font using CVE-2022-46689.
// The font must be specially prepared so that it skips past the last byte in every 16KB page.
// See BrotliPadding.swift for an implementation that adds this padding to WOFF2 fonts.
// credit: FontOverwrite
func overwriteFileWithDataImpl(originPath: String, replacementData: Data) -> Bool {
#if false
    let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].path
    
    let pathToRealTarget = originPath
    let originPath = documentDirectory + originPath
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
