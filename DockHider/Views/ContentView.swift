//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false
var noDiff = false
let defaults = UserDefaults.standard

@objc class InProg: NSObject {
    @objc func disableProg() { inProgress = false }
    @objc func setDiff() { noDiff = true }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var successful = false
    @State private var failedAlert = false
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
            
            /*Button("Hide Dock", action: {
                if !inProgress {
                    applyText = "Hiding dock..."
                    successful = applyDock(isVisible: false)
                    //ApplyingVariables.applyingText = " "
                    if !successful {
                        if noDiff == true {
                            applyText = "Dock already hidden!"
                        } else {
                            failedAlert = true
                        }
                    }
                }
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
            .alert(isPresented: $failedAlert) {
                Alert(
                    title: Text("An Error Occurred"),
                    message: Text("Action was unsuccessful."),
                    dismissButton: .default(Text("Ok"))
                )
            }
            
            Button("Revert Dock", action: {
                if !inProgress {
                    applyText = "Restoring dock..."
                    successful = applyDock(isVisible: true)
                    if !successful {
                        if noDiff == true {
                            applyText = "Dock already visible!"
                        } else {
                            failedAlert = true
                        }
                    }
                }
            })
            .padding(10)
            .background(Color.red)
            .cornerRadius(8)
            .foregroundColor(.white)
            
            Button("Hide Home Bar", action: {
                if !inProgress {
                    applyText = "Hiding home bar..."
                    successful = hideHomeBar()
                    //ApplyingVariables.applyingText = " "
                    if !successful {
                        failedAlert = true
                    }
                }
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)*/
            
            Button("Apply and Respring", action: {
                if !inProgress {
                    // set the defaults
                    applyText = "Setting defaults..."
                    defaults.set(hidingHomeBar, forKey: "HomeBarHidden")
                    defaults.set(hidingDock, forKey: "DockHidden")
                    
                    // apply the tweaks
                    applyText = "Applying tweaks..."
                    let lightMode: Bool = colorScheme == .light
                    applyTweaks(isVisible: !hidingDock, changesHomeBar: hidingHomeBar, isLightMode: lightMode)
                    //applyText = "Respringing..."
                    //respring()
                }
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
