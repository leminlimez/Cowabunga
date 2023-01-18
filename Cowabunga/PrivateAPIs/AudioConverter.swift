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

func customaudio(fileURL: URL) -> String? {
    // Converting options
    var options = FormatConverter.Options()
    options.format = AudioFileFormat.caf
    options.channels = 1
    options.sampleRate = 6500//11025
    options.bitDepth = 16
    // Temp Path
    let temporaryDirectoryURL = FileManager.default.temporaryDirectory
    let newURL = temporaryDirectoryURL.appendingPathComponent("outputAudio.caf")
    // Delete if old file in temp dir
    // CONVERT !
    let converter = FormatConverter(inputURL: fileURL, outputURL: newURL, options: options)
    converter.start { error in
        print("CONVERTER")
        print(error)
        print("CONVERTER END")
    }
    // Check file size
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: newURL.path)
        let fileSize = attributes[.size] as! Int64
        if fileSize > 15000 {
            UIApplication.shared.alert(body: "Your file is too big. Please crop or compress it to under 15 kB.")
            return nil
        }
    } catch {
        print("Error: Unable to check file size.")
        UIApplication.shared.alert(body: "Unable to verify file size.")
        return nil
    }
    // Base 64 Encoding
    var fileData = Data()
    do{
        fileData = try Data.init(contentsOf: newURL)
    }
    catch {
        print(error)
        UIApplication.shared.alert(body: "An unexpected error occurred.")
        return nil
    }
    let encoded:String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
    // Return base64
    return encoded
}
