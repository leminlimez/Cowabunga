//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false
@objc class InProg: NSObject {
    //private override init() {}
    
    @objc func disableProg() { inProgress = false }
}

// I am not experienced in swift so appologies for this part
struct ApplyingVariables {
    static var applyingText = " j"
}

struct ContentView: View {
    @State private var successful = false
    @State private var failedAlert = false
    @State private var successAlert = false
    
    var body: some View {
        VStack {
            Text("Dock Hider")
                .bold()
                .padding(.bottom, 10)
            Text(ApplyingVariables.applyingText)
                .padding(.bottom, 15)
            
            Button("Hide Dock", action: {
                ApplyingVariables.applyingText = "Hiding dock..."
                successful = applyDock(isVisible: false)
                //ApplyingVariables.applyingText = " "
                if !successful {
                    failedAlert = true
                } else {
                    successAlert = true
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
            .alert(isPresented: $successAlert) {
                Alert(
                    title: Text("Success!"),
                    message: Text("Please respring."),
                    dismissButton: .default(Text("Ok"))
                )
            }
            
            Button("Revert Dock", action: {
                ApplyingVariables.applyingText = "Restoring dock..."
                successful = applyDock(isVisible: true)
                if !successful {
                    failedAlert = true
                }
            })
            .padding(10)
            .background(Color.red)
            .cornerRadius(8)
            .foregroundColor(.white)
            
            Button("Respring", action: {
                respring()
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
