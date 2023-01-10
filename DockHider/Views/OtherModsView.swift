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
            
            HStack {
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
                            setPlistValue(plistPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist", backupName: "com.apple.MobileGestalt.plist", key: "ArtworkDeviceProductDescription", newValue: newModel) { succeeded in
                                if succeeded {
                                    CurrentModel = newModel
                                    // set the default
                                    defaults.set(newModel, forKey: "ModelName")
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
        }
    }
}

struct OtherModsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherModsView()
    }
}
