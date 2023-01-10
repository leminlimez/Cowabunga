//
//  AudioChangerView.swift
//  DockHider
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioChangerView: View {
    var SoundIdentifier: String
    
    var body: some View {
        var AppliedSound = UserDefaults.standard.string(forKey: SoundIdentifier+"_Applied") ?? "Default"
        VStack {
            NavigationView {
                List {
                    Section {
                        HStack {
                            Button("Default", action: {
                                
                            })
                                .padding(.horizontal, 8)
                        }
                    } header: {
                        Text("Choose a new sound")
                    }
                }
            }
        }
    }
}

struct AudioChangerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioChangerView(SoundIdentifier: "Charging")
    }
}
