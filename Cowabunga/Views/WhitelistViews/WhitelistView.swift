//
//  ContentView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI

// TODO: Translate

struct WhitelistView: View {
    @State var blacklist = true
    @State var banned = true
    @State var cdHash = true
    @State var inProgress = false
    @State var message = ""
    @State var banned_success = false
    @State var blacklist_success = false
    @State var hash_success = false
    @State var success = false
    @State var success_message = ""

    var body: some View {
            List {
                Section {
                    Toggle("Overwrite Blacklist", isOn: $blacklist)
                        .disabled(true)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .disabled(inProgress)
                    Toggle("Overwrite Banned Apps", isOn: $banned)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .disabled(inProgress)
                    Toggle("Overwrite CDHashes", isOn: $cdHash)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .disabled(inProgress)
                } header: {
                    Label("Options", systemImage: "gear")
                }
                Section {
                    Button(
                        action: {
                            Haptic.shared.play(.heavy)
                            inProgress = true
                            
                            if banned {
                                banned_success = Whitelist.overwriteBannedApps()
                            }
                            if cdHash {
                                hash_success = Whitelist.overwriteCdHashes()
                            } else {
                                banned_success = false
                                hash_success = false
                            }
                            success = Whitelist.overwriteBlacklist()
                            
                            // FIXME: Bad.
                            
                            if banned_success && hash_success {
                                success_message = "Successfully removed: Blacklist, Banned Apps, CDHashes\nDidn't overwrite: none"
                            } else if !banned_success && hash_success {
                                success_message = "Successfully removed: Blacklist, CDHashes\nDidn't overwrite: Banned Apps"
                            } else if banned_success && !hash_success {
                                success_message = "Successfully removed: Blacklist, Banned Apps\nDidn't overwrite: CDHashes"
                            } else {
                                success_message = "Successfully removed: Blacklist\nDidn't overwrite: Banned Apps, CDHashes"
                            }
                            
                            if success {
                                UIApplication.shared.alert(title: "Success", body: success_message, withButton: true)
                                inProgress = false
                                Haptic.shared.notify(.success)
                            } else {
                                UIApplication.shared.alert(title: "Error", body: "An error occurred while writing to the file.", withButton: true)
                                inProgress = false
                                Haptic.shared.notify(.error)
                            }
                            inProgress = false
                        },
                        label: { Label("Apply", systemImage: "app.badge.checkmark") }
                    )
                } header: {
                    Label("Make It So, Number One", systemImage: "arrow.right.circle")
                }
                
                Section {
                    NavigationLink(destination: FileContentsView()) {
                        Text("View contents of blacklist files")
                    }
                } header : {
                    Label("Advanced", systemImage: "wrench.and.screwdriver")
                }
                Section{}header:{Text("")}
            }
        
        .navigationTitle("Whitelist")
    }
}

struct WhitelistView_Previews: PreviewProvider {
    static var previews: some View {
        WhitelistView()
    }
}
