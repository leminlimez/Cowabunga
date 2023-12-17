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
//                if #unavailable(iOS 16) {
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
//                }
                
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
                            try togglePlistOption(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist", key: "CloudConfigurationUIComplete", value: new)
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
                    
                    Text("Disable Screen Time")
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
