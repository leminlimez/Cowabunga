//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isHidden: Bool = false
    
    var body: some View {
        VStack {
            Text("Dock Hider")
                .bold()
                .padding()
            HStack {
                Image(systemName: "platter.filled.bottom.iphone")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Toggle(isOn: $isHidden) {
                    Text("Dock Hidden")
                        .minimumScaleFactor(0.5)
                }.onChange(of: isHidden) { new in
                    
                }
                .padding(.leading, 10)
            }
            .padding(20)
            
            Button("Apply and respring", action: {
                
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
