//
//  AudioConverter.swift
//  Cowabunga
//
//  Created by Constantin Clerc on 14/01/2023.
//

import AudioKit
import AVFoundation
import SwiftUI
import UIKit

func customaudio(fileURL: URL, completion: @escaping (Data?) -> Void) {
    // config
    let fileLimit: Int = 14 // in kB
    
    DispatchQueue.global(qos: .userInteractive).async {
        // Temp Path
        let newURL = AudioFiles.getAudioDirectory()!.appendingPathComponent("USR_" + fileURL.deletingPathExtension().lastPathComponent + ".m4a")
        // Delete if old file in temp dir
        // CONVERT !
        let asset = AVURLAsset(url: fileURL)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        exporter?.outputFileType = AVFileType.m4a
        exporter?.outputURL = newURL
        exporter?.exportAsynchronously(completionHandler: {
            if let e = exporter {
                switch e.status {
                case .failed:
                    print("failed to convert audio")
                    UIApplication.shared.alert(body: "Failed to convert audio")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                case .cancelled:
                    print("audio conversion cancelled")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                default:
                    // Check file size
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                        let fileSize = attributes[.size] as! Int64
                        if fileSize > fileLimit*1000 {
                            print(fileSize)
                            UIApplication.shared.alert(body: "Your file is too big. Please crop or compress it to under "+String(fileLimit)+" kB.")
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        } else {
                            let fileData = try Data.init(contentsOf: fileURL)
                            DispatchQueue.main.async {
                                completion(fileData)
                            }
                        }
                    } catch {
                        print("Error: Unable to check file size.")
                        UIApplication.shared.alert(body: "Unable to verify file size.")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        })
    }
}
