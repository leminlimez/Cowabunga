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
    options.sampleRate = 11025
    options.bitDepth = 16
    // Temp Path
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    let newURL = URL(fileURLWithPath: "/var/containers/Bundle/Application/3B284421-75B1-4675-BFC5-A836A7EEE337/")
    let newURLWithFile = URL(fileURLWithPath: "\(newURL)")
    // Delete if old file in temp dir
    // CONVERT !
    let converter = FormatConverter(inputURL: fileURL, outputURL: newURL, options: options)
    converter.start { error in
        print("CONVERTER")
        print(error)
        UIApplication.shared.alert(body: "Cannot convert you're file \(error)")
        print("CONVERTER END")
    }
    // Check file size
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: newURLWithFile.path)
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
