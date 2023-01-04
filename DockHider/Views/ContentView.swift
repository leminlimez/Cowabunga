//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false
var noDiff = false

@objc class InProg: NSObject {
    @objc func disableProg() { inProgress = false }
    @objc func setDiff() { noDiff = true }
}

struct ContentView: View {
    @State private var successful = false
    @State private var failedAlert = false
    @State private var successAlert = false
    @State private var applyText = " "
    
    var body: some View {
        VStack {
            Text("Dock Hider")
                .bold()
                .padding(.bottom, 10)
            Text(applyText)
                .padding(.bottom, 15)
            
            Button("Hide Dock", action: {
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
            
            Button("Respring", action: {
                if !inProgress {
                    applyText = "Respringing..."
                    respring()
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
