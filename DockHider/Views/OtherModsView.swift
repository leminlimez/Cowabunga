//
//  OtherModsView.swift
//  DockHider
//
//  Created by lemin on 1/6/23.
//

import SwiftUI

struct OtherModsView: View {
    @State private var CurrentVersion: String = getPlistValue(plistPath: "/System/Library/CoreServices/SystemVersion.plist", key: "ProductVersion")
    @State private var CurrentModel: String = getPlistValue(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", key: "ArtworkDeviceProductDescription")
    @State private var CurrentSubType: Int = getCurrentDeviceSubType()
    @State private var CurrentSubTypeDisplay: String = "nil"
    
    struct DeviceSubType: Identifiable {
        var id = UUID()
        var key: Int
        var title: String
        var iOS16Only: Bool
    }
    
    // list of options
    @State var deviceSubTypes: [DeviceSubType] = [
        .init(key: Int(UIScreen.main.nativeBounds.height), title: "Default", iOS16Only: false),
        .init(key: 2436, title: "iPhone X Gestures", iOS16Only: false),
        .init(key: 2556, title: "Dynamic Island", iOS16Only: true),
        .init(key: 2796, title: "Dynamic Island Pro Max", iOS16Only: true)
    ]
    
    var body: some View {
        VStack {
            // title
            Text("Cowabunga")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            Text("Miscelaneous Modifications")
                .font(.title2)
                .padding(.bottom, 40)
            
            // software version
            if #available(iOS 15, *) {
                HStack {
                    Image(systemName: "gear.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Text("Software Version")
                        .minimumScaleFactor(0.5)
                        .padding(.trailing, 50)
                    
                    Button(CurrentVersion, action: {
                        let defaults = UserDefaults.standard
                        // create and configure alert controller
                        let alert = UIAlertController(title: "Input Software Version", message: "No respring required to apply.", preferredStyle: .alert)
                        // bring up the text prompt
                        alert.addTextField { (textField) in
                            textField.placeholder = "Version"
                            textField.text = defaults.string(forKey: "ProductVersion") ?? CurrentVersion
                        }
                        
                        // buttons
                        alert.addAction(UIAlertAction(title: "Apply", style: .default) { (action) in
                            // set the version
                            let newVersion: String = alert.textFields?[0].text! ?? CurrentVersion
                            if newVersion != "" {
                                setProductVersion(newVersion: newVersion) { succeeded in
                                    if succeeded {
                                        CurrentVersion = newVersion
                                        // set the default
                                        defaults.set(newVersion, forKey: "ProductVersion")
                                    } else {
                                        UIApplication.shared.alert(body: "Failed to apply system version change! The version must be shorter than your current device version.")
                                    }
                                }
                            }
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                            // cancel the process
                        })
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    })
                    .padding(.leading, 10)
                }
                
                // device name
                /*HStack {
                    Image(systemName: "iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    
                    Text("Model Name")
                        .minimumScaleFactor(0.5)
                        .padding(.trailing, 50)
                    
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
                            if newModel != "" {
                                setDeviceName(value: newModel) { succeeded in
                                    if succeeded {
                                        CurrentModel = newModel
                                        // set the default
                                        defaults.set(newModel, forKey: "ModelName")
                                    } else {
                                        UIApplication.shared.alert(body: "Failed to apply device model name! Name must be shorter than your current device name.")
                                    }
                                }
                            }
                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                            // cancel the process
                        })
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    })
                    .padding(.leading, 10)
                }*/
            }
            
            // device subtype
            HStack {
                Image(systemName: "ipodtouch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                    
                
                Text("Device SubType")
                    .minimumScaleFactor(0.5)
                    .padding(.trailing, 50)
                
                Button(CurrentSubTypeDisplay, action: {
                    // create and configure alert controller
                    let alert = UIAlertController(title: "Choose a device subset", message: "Respring to see changes", preferredStyle: .actionSheet)
                    
                    var iOS16 = false
                    if #available(iOS 16, *) {
                        iOS16 = true
                    }
                    
                    // create the actions
                    
                    for type in deviceSubTypes {
                        if !type.iOS16Only ||  iOS16 {
                            let newAction = UIAlertAction(title: type.title + " (" + String(type.key) + ")", style: .default) { (action) in
                                // apply the type
                                setPlistValueInt(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", backupName: "com.apple.MobileGestalt.plist", key: "ArtworkDeviceSubType", value: type.key) { succeeded in
                                    if succeeded {
                                        CurrentSubType = type.key
                                        CurrentSubTypeDisplay = type.title
                                        UIApplication.shared.alert(title: "Success!", body: "Please respring on the SpringBoard Tools page to finish applying changes.")
                                    } else {
                                        UIApplication.shared.alert(body: "Failed to apply DeviceSubType!")
                                    }
                                }
                            }
                            if CurrentSubType == type.key {
                                // add a check mark
                                newAction.setValue(true, forKey: "checked")
                            }
                            alert.addAction(newAction)
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                        // cancels the action
                    }
                    
                    // add the actions
                    alert.addAction(cancelAction)
                    
                    let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                    // present popover for iPads
                    alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                    alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                    
                    // present the alert
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                })
                    .padding(.leading, 10)
            }
        }
        .onAppear() {
            for sub in deviceSubTypes {
                if CurrentSubType == sub.key {
                    CurrentSubTypeDisplay = sub.title
                    break
                }
            }
        }
    }
}

struct OtherModsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherModsView()
    }
}
