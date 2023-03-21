//
//  CalculatorErrorManager.swift
//  Cowabunga
//
//  Created by lemin on 3/11/23.
//

import Foundation
import MacDirtyCowSwift
import SwiftUI

class CalculatorErrorManager {
    private static var savedCalculatorPath: String = ""
    private static var leet: String = ""
    
    static func getCalculatorURL() throws -> URL {
        if savedCalculatorPath != "" {
            return URL(fileURLWithPath: savedCalculatorPath)
        }
        
        let appDataPath = "/var/containers/Bundle/Application"
        for url in try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: appDataPath), includingPropertiesForKeys: []) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: try Data(contentsOf: url.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")), options: [], format: nil) as! [String: Any]
                if plist["MCMMetadataIdentifier"] != nil && plist["MCMMetadataIdentifier"]! as! String == "com.apple.calculator" {
                    savedCalculatorPath = url.path
                    return url
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        throw "Unable to find calculator app. Maybe you're on an iPad? :troll:"
    }
    
    static func applyErrorMessage(_ msg: String) throws {
        let calculatorBundleURL = try getCalculatorURL().appendingPathComponent("Calculator.app")
        let loctableURL = calculatorBundleURL.appendingPathComponent("Localizable.loctable")
        
        if FileManager.default.fileExists(atPath: loctableURL.path) {
            // iOS 16
            let plistData = try Data(contentsOf: loctableURL)
            var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
            
            let newValue: [String: String] = [
                "Error": msg
            ]
            
            // loop through each localization and apply the results
            for (k, v) in plist {
                if let prop = v as? [String: String], prop["Error"] != nil {
                    plist[k] = newValue
                }
            }
            
            // Apply and save the plist
            let newData = try addEmptyData(matchingSize: plistData.count, to: plist)
            try MDC.overwriteFile(at: loctableURL.path, with: newData)
        } else {
            // iOS 15 and below
            for file in try FileManager.default.contentsOfDirectory(at: calculatorBundleURL, includingPropertiesForKeys: nil) {
                if file.lastPathComponent.contains("lproj") {
                    let fileURL = file.appendingPathComponent("Localizable.strings")
                    do {
                        let plistData = try Data(contentsOf: fileURL)
                        let plist: [String: String] = ["Error": msg]
                        let newData = try addEmptyData(matchingSize: plistData.count, to: plist)
                        try MDC.overwriteFile(at: fileURL.path, with: newData)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        // Save plist
        UserDefaults.standard.set(msg, forKey: "CalculatorErrorMessage")
    }
    
    
    // FIXME: what on god's green earth
    static func nothing() {
        Haptic.shared.play(.light)
        print("nope")
        leet = ""
    }
    // funny.
    static func something(number: String) {
        Haptic.shared.play(.light)
        print("yep")
        leet = leet + number
        print(leet)
        if leet == "1337" {
            Haptic.shared.notify(.success)
            UIApplication.shared.alert(title: "Access Granted", body: "Welcome, Neo")
            leet = ""
        }
    }
}
