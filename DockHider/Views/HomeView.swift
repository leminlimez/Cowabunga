//
//  HomeView.swift
//  DockHider
//
//  Created by lemin on 1/17/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    // apply all tweaks button
                    Button(action: {
                        applyTweaks()
                    }) {
                        if #available(iOS 15.0, *) {
                            Text("Apply all")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .buttonStyle(.bordered)
                                .tint(.blue)
                                .cornerRadius(8)
                        } else {
                            // Fallback on earlier versions
                            Text("Apply all")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .cornerRadius(8)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // respring button
                    Button(action: {
                        respring()
                    }) {
                        if #available(iOS 15.0, *) {
                            Text("Respring")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .buttonStyle(.bordered)
                                .tint(.red)
                                .cornerRadius(8)
                        } else {
                            // Fallback on earlier versions
                            Text("Respring")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                } header: {
                    Text("Tweak Options")
                }
                Section {
                    
                } header: {
                    Text("Preferences")
                }
            }
            .navigationTitle("Cowabunga")
        }
    }
    
    func applyTweaks() {
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
