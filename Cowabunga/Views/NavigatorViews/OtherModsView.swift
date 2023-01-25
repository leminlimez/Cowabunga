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
        .init(key: getOriginalDeviceSubType(), title: "Default", iOS16Only: false),
        .init(key: 2436, title: "iPhone X Gestures", iOS16Only: false),
        .init(key: 2556, title: "Dynamic Island", iOS16Only: true),
        .init(key: 2796, title: "Dynamic Island Pro Max", iOS16Only: true)
    ]
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        // carrier name changer
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            
                            Text("Carrier Name")
                                .minimumScaleFactor(0.5)
                            
                            Spacer()
                            
                            Button("Edit", action: {
                                // create and configure alert controller
                                let alert = UIAlertController(title: "Input Carrier Name", message: "Reboot needed to apply.", preferredStyle: .alert)
                                // bring up the text prompt
                                alert.addTextField { (textField) in
                                    textField.placeholder = "New Carrier Name"
                                    textField.text = CurrentCarrier
                                }
                                
                                // buttons
                                alert.addAction(UIAlertAction(title: "Apply", style: .default) { (action) in
                                    // set the version
                                    let newName: String = alert.textFields?[0].text! ?? ""
                                    // set the defaults
                                    UserDefaults.standard.set(newName, forKey: "CarrierName")
                                    if newName != "" {
                                        UIApplication.shared.alert(title: "Applying carrier...", body: "Please wait", animated: false, withButton: false)
                                        setCarrierName(newName: newName) { succeeded in
                                            UIApplication.shared.dismissAlert(animated: true)
                                            // delay
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                if succeeded {
                                                    UIApplication.shared.alert(title: "Carrier Name Successfully Changed to \"" + newName + "\"!", body: "Please reboot to see changes.")
                                                } else {
                                                    UIApplication.shared.alert(body: "An error occurred while trying to change the carrier name.")
                                                }
                                            }
                                        }
                                    } else {
                                        UIApplication.shared.alert(body: "No name was inputted!")
                                    }
                                })
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                                    // cancel the process
                                })
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            })
                            .foregroundColor(.blue)
                            .padding(.leading, 10)
                        }
                    } header: {
                        Text("Safe")
                    }
                    Section {
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
                                
                                Spacer()
                                
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
                                .foregroundColor(.blue)
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
                                                    // delay
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        UIApplication.shared.alert(body: "Failed to apply device model name! File overwrite failed unexpectedly.")
                                                    }
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
                            
                        }
                        
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
                                
                                
                                Text("Device SubType")
                                    .minimumScaleFactor(0.5)
                                
                                Spacer()
                                
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
                                                setPlistValueInt(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", key: "ArtworkDeviceSubType", value: type.key) { succeeded in
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
                                    
                                    let resetAction = UIAlertAction(title: "Reset Default SubType", style: .destructive) { (action) in
                                        // resets the device subtype
                                        UIApplication.shared.confirmAlert(title: "Are you sure you want to reset the Default SubType?", body: "You should only reset the Default SubType if it is incorrect or stuck on another value.", onOK: {
                                            // reset the subtypes
                                            let succeeded: Bool = resetDeviceSubType()
                                            if succeeded {
                                                // successfully reset
                                                UIApplication.shared.alert(title: "Successfully reset the Default SubType!", body: "The Default SubType should now be accurate to your device.")
                                            } else {
                                                // failed to apply
                                                let newUIAlert = UIAlertController(title: "Failed to determine Default SubType!", message: "Please submit an issue on github and include your device model.", preferredStyle: .alert)
                                                newUIAlert.addAction(.init(title: "Ok", style: .cancel))
                                                newUIAlert.addAction(.init(title: "Submit Issue", style: .default, handler: { _ in
                                                    // send them to the issues page
                                                    UIApplication.shared.open(URL(string: "https://github.com/leminlimez/Cowabunga/issues")!)
                                                }))
                                                UIApplication.shared.present(alert: newUIAlert)
                                            }
                                        }, noCancel: false)
                                    }
                                    
                                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
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
                                })
                                .foregroundColor(.blue)
                                .padding(.leading, 10)
                            }
                        }
                    } header: {
                        Text("Use at your own risk")
                    }
                }
                .navigationTitle("Miscellaneous")
            }
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
    }
}

struct OtherModsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherModsView()
    }
}
