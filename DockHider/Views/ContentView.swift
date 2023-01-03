//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var successful = false
    @State private var failedAlert = false
    
    var body: some View {
        VStack {
            Text("Dock Hider")
                .bold()
                .padding(.bottom, 35)
            
            Button("Hide Dock", action: {
                successful = applyDock(isVisible: false)
                if !successful {
                    failedAlert = true
                }
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
            .alert(isPresented: $failedAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Action was unsuccessful."),
                    dismissButton: .default(Text("Ok"))
                )
            }
            
            Button("Revert Dock", action: {
                // check OS version
                if #available(iOS 15.0, *) {
                    // simply respring
                    respring()
                } else {
                    // apply the old dock for ios 14
                    successful = applyDock(isVisible: true)
                    if !successful {
                        failedAlert = true
                    }
                }
            })
            .padding(10)
            .background(Color.red)
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
