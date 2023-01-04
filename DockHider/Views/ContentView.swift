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
            
            Button("Apply and Respring", action: {
                if !inProgress {
                    // set the defaults
                    applyText = "Setting defaults..."
                    defaults.set(hidingFolderBG, forKey: "FolderBGHidden")
                    defaults.set(hidingHomeBar, forKey: "HomeBarHidden")
                    defaults.set(hidingDock, forKey: "DockHidden")
                    
                    // apply the tweaks
                    // apply dark dock
                    applyText = "Applying to dark dock file..."
                    overwriteFile(isVisible: !hidingDock, typeOfFile: "Dock", isDark: true) { succeededForDark in
                        if succeededForDark == "Success" {
                            // apply light dock
                            applyText = "Applying to light dock file..."
                            overwriteFile(isVisible: !hidingDock, typeOfFile: "Dock", isDark: false) { succeededForLight in
                                if succeededForLight == "Success" {
                                    if hidingHomeBar {
                                        applyText = "Applying to home bar..."
                                        overwriteFile(isVisible: true, typeOfFile: "HomeBar", isDark: true) { succeededForHomeBar in
                                            if succeededForHomeBar == "Success" {
                                                // apply folder background
                                                // i forgot functions existed when making this ._.
                                                if hidingFolderBG {
                                                    applyText = "Failed to apply home bar. Applying folder background..."
                                                    overwriteFile(isVisible: true, typeOfFile: "FolderBG", isDark: true) { succeededForFolderBG in
                                                        if succeededForFolderBG == "Success" {
                                                            // respring
                                                            applyText = "Respringing..."
                                                        } else {
                                                            // respring anyway
                                                            applyText = "Failed to apply folder background. Respringing..."
                                                        }
                                                        respring()
                                                    }
                                                } else {
                                                    // respring
                                                    applyText = "Respringing..."
                                                    respring()
                                                }
                                            } else {
                                                if hidingFolderBG {
                                                    applyText = "Failed to apply home bar. Applying folder background..."
                                                    overwriteFile(isVisible: true, typeOfFile: "FolderBG", isDark: true) { succeededForFolderBG in
                                                        if succeededForFolderBG == "Success" {
                                                            // respring
                                                            applyText = "Respringing..."
                                                        } else {
                                                            // respring anyway
                                                            applyText = "Failed to apply folder background. Respringing..."
                                                        }
                                                        respring()
                                                    }
                                                } else {
                                                    // respring anyway
                                                    applyText = "Failed to apply home bar. Respringing..."
                                                    respring()
                                                }
                                            }
                                        }
                                    } else if hidingFolderBG {
                                        applyText = "Applying to folder background..."
                                        overwriteFile(isVisible: true, typeOfFile: "FolderBG", isDark: true) { succeededForFolderBG in
                                            if succeededForFolderBG == "Success" {
                                                // respring
                                                applyText = "Respringing..."
                                            } else {
                                                // respring anyway
                                                applyText = "Failed to apply folder background. Respringing..."
                                            }
                                            respring()
                                        }
                                    } else {
                                        // respring
                                        applyText = "Respringing..."
                                        respring()
                                    }
                                } else {
                                    applyText = "Failed to apply light dock"
                                }
                            }
                        } else {
                            applyText = "Failed to apply dark dock"
                        }
                    }
                    // let lightMode: Bool = colorScheme == .light
                    // applyTweaks(isVisible: !hidingDock, changesHomeBar: hidingHomeBar, isLightMode: lightMode)
                    //applyText = "Respringing..."
                    //respring()
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
