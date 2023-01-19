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

func customaudio(fileURL: URL, completion: @escaping (String?) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
        // Temp Path
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let newURL = temporaryDirectoryURL.appendingPathComponent("outputAudio.m4a")
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
                        if fileSize > 12000 {
                            print(fileSize)
                            UIApplication.shared.alert(body: "Your file is too big. Please crop or compress it to under 12 kB.")
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                    } catch {
                        print("Error: Unable to check file size.")
                        UIApplication.shared.alert(body: "Unable to verify file size.")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                    // Base 64 Encoding
                    var fileData = Data()
                    do{
                        fileData = try Data.init(contentsOf: fileURL)
                    }
                    catch {
                        print(error)
                        UIApplication.shared.alert(body: "An unexpected error occurred.")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                    let encoded:String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
                    // Return base64
                    DispatchQueue.main.async {
                        completion(encoded)
                    }
                }
            }
        })
    }
}
