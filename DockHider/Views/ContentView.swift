//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false
var noDiff = false
var onHomeBar = false
let defaults = UserDefaults.standard

@objc class InProg: NSObject {
    @objc func disableProg() { inProgress = false }
    @objc func setDiff() { noDiff = true }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var successful = false
    @State private var failedAlert = false
    @State private var disabledFolderBlur = defaults.bool(forKey: "FolderBlurDisabled")
    @State private var hidingFolderBG = defaults.bool(forKey: "FolderBGHidden")
    @State private var hidingHomeBar = defaults.bool(forKey: "HomeBarHidden")
    @State private var hidingDock = defaults.object(forKey: "DockHidden") as? Bool ?? true
    @State private var applyText = " "
    
    var body: some View {
        VStack {
            Text("Dock Hider")
                .bold()
                .padding(.bottom, 10)
            Text(applyText)
                .padding(.bottom, 15)
            
            HStack {
                Image(systemName: "platter.filled.bottom.iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Toggle(isOn: $hidingDock) {
                    Text("Hide Dock")
                        .minimumScaleFactor(0.5)
                }
                .padding(.leading, 10)
            }
            HStack {
                Image(systemName: "iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Toggle(isOn: $hidingHomeBar) {
                    Text("Hide Home Bar")
                        .minimumScaleFactor(0.5)
                }
                .padding(.leading, 10)
            }
            HStack {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Toggle(isOn: $hidingFolderBG) {
                    Text("Hide Folder Background")
                        .minimumScaleFactor(0.5)
                }
                .padding(.leading, 10)
            }
            HStack {
                Image(systemName: "folder.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Toggle(isOn: $disabledFolderBlur) {
                    Text("Disable Folder Blur")
                        .minimumScaleFactor(0.5)
                }
                .padding(.leading, 10)
            }
            
            Button("Apply and Respring", action: {
                if !inProgress {
                    // set the defaults
                    applyText = "Setting defaults..."
                    defaults.set(disabledFolderBlur, forKey: "FolderBlurDisabled")
                    defaults.set(hidingFolderBG, forKey: "FolderBGHidden")
                    defaults.set(hidingHomeBar, forKey: "HomeBarHidden")
                    defaults.set(hidingDock, forKey: "DockHidden")
                    
                    // apply the tweaks
                    // apply dark dock
                    applyText = "Applying to dark dock file..."
                    overwriteFile(isVisible: !hidingDock, typeOfFile: "Dock", isDark: true) { succeededForDark in
                        if succeededForDark  {
                            // apply light dock
                            applyText = "Applying to light dock file..."
                            overwriteFile(isVisible: !hidingDock, typeOfFile: "Dock", isDark: false) { succeededForLight in
                                if !succeededForLight  {
                                    print("Failed to apply light dock")
                                }
                            }
                        } else {
                            print("Failed to apply dark dock")
                        }
                    }
                    
                    // apply home bar
                    if hidingHomeBar {
                        applyText = "Applying to home bar file..."
                        overwriteFile(isVisible: true, typeOfFile: "HomeBar", isDark: false) { succeeded in
                            if !succeeded {
                                print("Failed to apply home bar")
                            }
                        }
                    }
                    
                    // apply hide folder bg
                    if hidingFolderBG {
                        applyText = "Applying to folder background file..."
                        overwriteFile(isVisible: true, typeOfFile: "FolderBG", isDark: true) { succeeded in
                            if !succeeded {
                                print("Failed to apply folder background")
                            }
                        }
                    }
                    
                    // apply disabling folder blur
                    if disabledFolderBlur {
                        applyText = "Disabling folder blur..."
                        overwriteFile(isVisible: true, typeOfFile: "FolderBlur", isDark: true) { succeeded in
                            if !succeeded {
                                print("Failed to disable folder blur")
                            }
                        }
                    }
                    
                    // respring and apply changes
                    applyText = "Respringing..."
                    respring()
                }
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
            .onChange(of: inProgress) { new in
                if inProgress == false {
                    if onHomeBar {
                        applyText = "Applying to home bar file..."
                    } else {
                        applyText = "Respringing..."
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
