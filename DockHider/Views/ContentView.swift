//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isVisible: Bool = true
    @State private var successful = false
    @State private var failedAlert = false
    
    var body: some View {
        VStack {
            Text("Dock Hider")
                .bold()
                .padding()
            HStack {
                Image(systemName: "platter.filled.bottom.iphone")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Toggle(isOn: $isVisible) {
                    Text("Dock Visible")
                        .minimumScaleFactor(0.5)
                }
                .padding(.leading, 10)
            }
            .padding(20)
            
            Button("Apply", action: {
                successful = applyDock(isVisible: isVisible)
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
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
