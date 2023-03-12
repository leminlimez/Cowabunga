//
//  OtherModsView.swift
//  Cowabunga
//
//  Created by lemin on 1/6/23.
//

import SwiftUI

struct OtherModsView: View {
    @State private var CurrentVersion: String = getPlistValue(plistPath: "/System/Library/CoreServices/SystemVersion.plist", key: "ProductVersion")
    @State private var CurrentModel: String = getPlistValue(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", key: "ArtworkDeviceProductDescription")
    @State private var CurrentCarrier: String = UserDefaults.standard.string(forKey: "CarrierName") ?? ""
    
    @State private var deviceRes = [Int(UIScreen.main.nativeBounds.width), Int(UIScreen.main.nativeBounds.height)]
    
    @State private var CurrentSubType: Int = getCurrentDeviceSubType()
    @State private var CurrentSubTypeDisplay: String = "nil"
    
    @State private var supervised: Bool = UserDefaults.standard.bool(forKey: "IsSupervised")
    
    @State private var screenTimeEnabled: Bool = FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist")
    @State private var internet_showed_once = false
    
    struct DeviceSubType: Identifiable {
        var id = UUID()
        var key: Int
        var title: String
        var iOS16Only: Bool
    }
    
    // list of options
    @State var deviceSubTypes: [DeviceSubType] = [
        .init(key: getOriginalDeviceSubType(), title: NSLocalizedString("Default", comment: "default device subtype"), iOS16Only: false),
        .init(key: 2436, title: NSLocalizedString("iPhone X Gestures", comment: "x gestures"), iOS16Only: false),
        .init(key: 2556, title: NSLocalizedString("Dynamic Island", comment: "iPhone 14 Pro SubType"), iOS16Only: true),
        .init(key: 2796, title: NSLocalizedString("Dynamic Island Pro Max", comment: "iPhone 14 Pro Max SubType"), iOS16Only: true)
    ]
    
    var body: some View {
        List {
            Section {
                // delete shortcut banner
                HStack {
                    Image(systemName: "pencil.slash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Delete Shortcut Banners")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button("Delete", action: {
                        let succeeded = modifyShortcutApp(modifying: ShortcutAppMod.deleteBanner)
                        if succeeded {
                            UIApplication.shared.alert(title: "Success!", body: "The shortcut banner will no longer appear for current shortcuts. Please respring to finalize.")
                        } else {
                            UIApplication.shared.alert(body: "An error occurred while trying to delete shortcut banners.")
                        }
                    })
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                }
                
                // set shortcut apps to appclip
                HStack {
                    Image(systemName: "appclip")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Enable Shortcut Apps as Appclips")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button("Enable", action: {
                        let succeeded = modifyShortcutApp(modifying: ShortcutAppMod.modifyAppClips, true)
                        if succeeded {
                            UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("Please respring to see changes.", comment: ""))
                        } else {
                            UIApplication.shared.alert(body: NSLocalizedString("An error occurred while trying to enable appclip icons.", comment: "Unable to enable app clips (NOT WEBCLIPS, if your language does not have a word for this then ignore)"))
                        }
                    })
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                }
                
                // disable shortcut apps to appclip
                HStack {
                    Image(systemName: "app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Disable Shortcut Apps as Appclips")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button("Disable", action: {
                        let succeeded = modifyShortcutApp(modifying: ShortcutAppMod.modifyAppClips, false)
                        if succeeded {
                            UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("Please respring to see changes.", comment: ""))
                        } else {
                            UIApplication.shared.alert(body: NSLocalizedString("An error occurred while trying to disable appclip icons.", comment: "Unable to enable app clips (NOT WEBCLIPS, if your language does not have a word for this then ignore)"))
                        }
                    })
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                }
            } header: {
                Label("Shortcut Apps", systemImage: "square.stack.3d.up")
            }
            
            Section {
                // custom settings
                HStack {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Extra Preferences")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button("Enable", action: {
                        let succeeded = createSettingsPage()
                        if succeeded {
                            if #available(iOS 16, *) {
                                UIApplication.shared.open(URL(string: "App-prefs:Phone")!)
                            } else {
                                UIApplication.shared.open(URL(string: "App-prefs:Photos")!)
                            }
                        } else {
                            UIApplication.shared.alert(body: NSLocalizedString("An error occurred while trying to enable extra settings.", comment: ""))
                        }
                    })
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                }
                
                // supervise
                HStack {
                    Image(systemName: "iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Supervised")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Toggle(isOn: $supervised) {
                        
                    }.onChange(of: supervised) { new in
                        // set the user defaults
                        UserDefaults.standard.set(new, forKey: "IsSupervised")
                        // set the value
                        do {
                            try togglePlistOption(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist", key: "IsSupervised", value: new)
                        } catch {
                            print("Failed")
                        }
                    }
                    .padding(.leading, 10)
                }
                
                // screen time
                HStack {
                    Image(systemName: "hourglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Screen Time Enabled")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Toggle(isOn: $screenTimeEnabled) {
                        
                    }.onChange(of: screenTimeEnabled) { new in
                        // set the value
                        do {
                            let webconnected = isInternetAvailable()
                            if webconnected == true && internet_showed_once == false {
                                UIApplication.shared.alert(title: NSLocalizedString("Your device is connected to internet!", comment: ""), body: NSLocalizedString("This could cause issues. Make sure to disable data or Wi-Fi.", comment: "screentime process"))
                            screenTimeEnabled = FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist")
                            internet_showed_once = true
                            }
                            else {
                                try modifyScreenTime(enabled: screenTimeEnabled)
                                UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("Screen time was successfully disabled, please reboot to finish application. You will be able to enable connection after restart.", comment: ""))
                            }
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }
                    .padding(.leading, 10)
                }
        } header: {
            Label("More Settings", systemImage: "gearshape")
        }
            
            Section {
                // software version
//                if #available(iOS 15, *) {
//                    HStack {
//                        Image(systemName: "gear.circle")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(.blue)
//
//                        Text("Software Version")
//                            .minimumScaleFactor(0.5)
//
//                        Spacer()
//
//                        Button(CurrentVersion, action: {
//                            let defaults = UserDefaults.standard
//                            // create and configure alert controller
//                            let alert = UIAlertController(title: NSLocalizedString("Input Software Version", comment: "Header for inputting custom iOS version"), message: NSLocalizedString("No respring required to apply.", comment: ""), preferredStyle: .alert)
//                            // bring up the text prompt
//                            alert.addTextField { (textField) in
//                                textField.placeholder = "Version"
//                                textField.text = defaults.string(forKey: "ProductVersion") ?? CurrentVersion
//                                textField.keyboardType = .decimalPad
//                            }
//
//                            // buttons
//                            alert.addAction(UIAlertAction(title: NSLocalizedString("Apply", comment: ""), style: .default) { (action) in
//                                // set the version
//                                let newVersion: String = alert.textFields?[0].text! ?? CurrentVersion
//                                if newVersion != "" {
//                                    do {
//                                        let _ = try setValueInSystemVersionPlist(key: "ProductVersion", value: newVersion)
//                                        CurrentVersion = newVersion
//                                        // set the default
//                                        defaults.set(newVersion, forKey: "ProductVersion")
//                                    } catch {
//                                        UIApplication.shared.alert(body: NSLocalizedString("Failed to apply system version change! The version must be shorter than your current device version.\n\n\(error.localizedDescription)", comment: ""))
//                                    }
//                                }
//                            })
//                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
//                                // cancel the process
//                            })
//                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
//                        })
//                        .foregroundColor(.blue)
//                        .padding(.leading, 10)
//                    }
                    
                    // resolution setter
                    /*HStack {
                        Image(systemName: "squareshape.controlhandles.on.squareshape.controlhandles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        
                        Text("Device Resolution")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button("\(deviceRes[0])x\(deviceRes[1])", action: {
                            // ask the user for a custom size
                            let sizeAlert = UIAlertController(title: NSLocalizedString("Enter Dimensions", comment: "Entering custom resolution"), message: "", preferredStyle: .alert)
                            // bring up the text prompts
                            sizeAlert.addTextField { (textField) in
                                // text field for width
                                textField.placeholder = NSLocalizedString("Width", comment: "Width of custom resolution")
                                textField.text = String(deviceRes[0])
                                textField.keyboardType = .decimalPad
                            }
                            sizeAlert.addTextField { (textField) in
                                // text field for height
                                textField.placeholder = NSLocalizedString("Height", comment: "Height of custom resolution")
                                textField.text = String(deviceRes[1])
                                textField.keyboardType = .decimalPad
                            }
                            sizeAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { (action) in
                                // set the sizes
                                let first = sizeAlert.textFields![0].text
                                if first != nil && Int(first!) != nil {
                                    deviceRes[0] = Int(first!)!
                                }
                                
                                let second = sizeAlert.textFields![1].text
                                if second != nil && Int(second!) != nil {
                                    deviceRes[1] = Int(second!)!
                                }
                                
                                // credit:
                                func createPlist(at url: URL) throws {
                                    let 💀 : [String: Any] = [
                                        "canvas_height": deviceRes[0],
                                        "canvas_width": deviceRes[1],
                                    ]
                                    let data = NSDictionary(dictionary: 💀)
                                    data.write(toFile: url.path, atomically: true)
                                }
                                
                                UIApplication.shared.confirmAlert(title: NSLocalizedString("Resolution will now apply", comment: ""), body: NSLocalizedString("Reboot to revert resolution changes. It will auto respring when done", comment: "Successfully applying custom resolution"), onOK: {
                                    do {
                                        let tmpPlistURL = URL(fileURLWithPath: "/var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist")
                                        try? FileManager.default.removeItem(at: tmpPlistURL)
                                        
                                        try createPlist(at: tmpPlistURL)
                                        
                                        let aliasURL = URL(fileURLWithPath: "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist")
                                        try? FileManager.default.removeItem(at: aliasURL)
                                        try FileManager.default.createSymbolicLink(at: aliasURL, withDestinationURL: tmpPlistURL)
                                        xpc_crash("com.apple.cfprefsd.daemon")
                                        xpc_crash("com.apple.backboard.TouchDeliveryPolicyServer")
                                        restartBackboard()
                                    } catch {
                                        print("An error occurred: \(error.localizedDescription)")
                                        UIApplication.shared.alert(body: NSLocalizedString("Failed to apply resolution:", comment: "Failing to apply custom resolution") + " \(error.localizedDescription)")
                                    }
                                }, noCancel: false)
                            })
                            sizeAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                // cancel the process
                            })
                            UIApplication.shared.windows.first?.rootViewController?.present(sizeAlert, animated: true, completion: nil)
                        })
                        .foregroundColor(.blue)
                        .padding(.leading, 10)
                    }*/
                    
                    // device name
                    /*HStack {
                     Image(systemName: "iphone")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 24, height: 24)
                     .foregroundColor(.blue)
                     
                     
                     Text("Model Name")
                     .minimumScaleFactor(0.5)
                     
                     Spacer()
                     
                     Button(CurrentModel, action: {
                     let defaults = UserDefaults.standard
                     // create and configure alert controller
                     let alert = UIAlertController(title: "Input Model Name", message: "No respring required to apply.", preferredStyle: .alert)
                     // bring up the text prompt
                     alert.addTextField { (textField) in
                     textField.placeholder = "Model"
                     textField.text = defaults.string(forKey: "ModelName") ?? CurrentModel
                     }
                     
                     // buttons
                     alert.addAction(UIAlertAction(title: "Apply", style: .default) { (action) in
                     // set the version
                     let newModel: String = alert.textFields?[0].text! ?? CurrentModel
                     let validChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890.,_/")
                     let newName: String = newModel.filter{validChars.contains($0)}
                     if newName != "" {
                     UIApplication.shared.alert(title: "Applying model name...", body: "Please wait", animated: false, withButton: false)
                     setModelName(value: newName) { succeeded in
                     UIApplication.shared.dismissAlert(animated: true)
                     if succeeded {
                     CurrentModel = newName
                     // set the default
                     defaults.set(newName, forKey: "ModelName")
                     } else {
                     UIApplication.shared.alert(body: "Failed to apply device model name! File overwrite failed unexpectedly.")
                     }
                     }
                     } else {
                     UIApplication.shared.alert(body: "Failed to apply device model name! Please enter a valid name.")
                     }
                     })
                     alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                     // cancel the process
                     })
                     UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                     })
                     .padding(.leading, 10)
                     }*/
                    
                    // export mobilegestalt
                    /*HStack {
                     Image(systemName: "iphone")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 24, height: 24)
                     .foregroundColor(.blue)
                     
                     
                     Text("Mobilegestalt Export")
                     .minimumScaleFactor(0.5)
                     
                     Spacer()
                     
                     Button("Export", action: {
                     let plistPath: String = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
                     do {
                     let archiveURL: URL? = try URL(fileURLWithPath: plistPath)
                     // show share menu
                     let avc = UIActivityViewController(activityItems: [archiveURL!], applicationActivities: nil)
                     let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                     avc.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                     avc.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                     UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
                     } catch {
                     UIApplication.shared.alert(body: "Failed.")
                     }
                     })
                     .padding(.leading, 10)
                     }*/
                    
//                }
                
                // region restrictions
                /*HStack {
                 Image(systemName: "ipodtouch")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 24, height: 24)
                 .foregroundColor(.blue)
                 
                 
                 Text("Region Restrictions")
                 .minimumScaleFactor(0.5)
                 
                 Spacer()
                 
                 Button("Test", action: {
                 setRegion() { succeeded in
                 print(succeeded)
                 }
                 })
                 .foregroundColor(.blue)
                 .padding(.leading, 10)
                 }*/
                
                // device subtype
                if UIDevice.current.userInterfaceIdiom == .phone {
                    HStack {
                        Image(systemName: "ipodtouch")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        
                        
                        Text("Gestures / Dynamic Island")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button(CurrentSubTypeDisplay, action: {
                            showSubTypeChangerPopup()
                        })
                        .foregroundColor(.blue)
                        .padding(.leading, 10)
                    }
                }
            } header: {
                Label("Use at your own risk", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Miscellaneous")
        .navigationViewStyle(.stack)
        .onAppear() {
            for sub in deviceSubTypes {
                if CurrentSubType == sub.key {
                    CurrentSubTypeDisplay = sub.title
                    break
                }
            }
        }
    }
    
    func showSubTypeChangerPopup() {
        // create and configure alert controller
        let alert = UIAlertController(title: NSLocalizedString("Choose a device subtype", comment: ""), message: NSLocalizedString("Respring to see changes", comment: ""), preferredStyle: .actionSheet)
        
        var iOS16 = false
        if #available(iOS 16, *) {
            iOS16 = true
        }
        
        // create the actions
        
        for type in deviceSubTypes {
            if !type.iOS16Only ||  iOS16 {
                let newAction = UIAlertAction(title: type.title + " (" + String(type.key) + ")", style: .default) { (action) in
                    // apply the type
                    let succeeded = setPlistValueInt(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", key: "ArtworkDeviceSubType", value: type.key)
                    if succeeded {
                        CurrentSubType = type.key
                        CurrentSubTypeDisplay = type.title
                        UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("Please respring to finish applying changes.", comment: ""))
                    } else {
                        UIApplication.shared.alert(body: NSLocalizedString("Failed to apply Device SubType!", comment: "failed to apply subtype"))
                    }
                }
                if CurrentSubType == type.key {
                    // add a check mark
                    newAction.setValue(true, forKey: "checked")
                }
                alert.addAction(newAction)
            }
        }
        
        let resetAction = UIAlertAction(title: NSLocalizedString("Reset Default SubType", comment: ""), style: .destructive) { (action) in
            // resets the device subtype
            UIApplication.shared.confirmAlert(title: NSLocalizedString("Are you sure you want to reset the Default SubType?", comment: ""), body: "You should only reset the Default SubType if it is incorrect or stuck on another value.", onOK: {
                // reset the subtypes
                let succeeded: Bool = resetDeviceSubType()
                if succeeded {
                    // successfully reset
                    UIApplication.shared.alert(title: "Successfully reset the Default SubType!", body: "The Default SubType should now be accurate to your device.")
                    // set the new
                    for (i, v) in deviceSubTypes.enumerated() {
                        if v.title == "Default" {
                            deviceSubTypes[i].key = getOriginalDeviceSubType()
                        }
                    }
                } else {
                    // failed to apply
                    let newUIAlert = UIAlertController(title: "Failed to determine Default SubType!", message: "Please submit an issue on github and include your device model: \(UIDevice().machineName).", preferredStyle: .alert)
                    newUIAlert.addAction(.init(title: "Cancel", style: .cancel))
                    newUIAlert.addAction(.init(title: "Submit Issue", style: .default, handler: { _ in
                        // send them to the issues page
                        UIApplication.shared.open(URL(string: "https://github.com/leminlimez/Cowabunga/issues")!)
                    }))
                    UIApplication.shared.present(alert: newUIAlert)
                }
            }, noCancel: false)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            // cancels the action
        }
        
        // add the actions
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
        // present popover for iPads
        alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
        
        // present the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

struct OtherModsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherModsView()
    }
}
