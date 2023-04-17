//
//  SettingsView.swift
//  DirtyJIT
//
//  Created by Анохин Юрий on 05.03.2023.
//

import SwiftUI

@available(iOS 15.0, *)
struct DirtySettingsView: View {
    @Binding var firstTime: Bool
    let jit = JIT.shared
    
    var body: some View {
        List {
            Section("Options") {
                Button("Replace iPhoneDebug.pem") {
                    UIApplication.shared.confirmAlert(title: "Warning", body: "This will replace the default certificate with a custom one to allow mounting the custom DeveloperDiskImage.", onOK: {
                        jit.replaceDebug()
                    }, noCancel: false)
                }
            }
            
            Section {
                Button("Show Instructions again") {
                    firstTime = true
                }
                .foregroundColor(Color.red)
                .font(Font.headline.weight(.bold))
                
                Button("Reset All") {
                    UIApplication.shared.confirmAlert(title: "Warning", body: "This means you will reset ALL user data, do you want to continue?", onOK: {
                        UIApplication.shared.alert(title: "Loading", body: "Please wait...", withButton: false)
                        
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }, noCancel: false)
                }
                .foregroundColor(Color.red)
                .font(Font.headline.weight(.bold))
            }
            
            Section("Credits") {
                HStack {
                    AsyncImage (
                        url: URL(string: "https://avatars.githubusercontent.com/u/87825638?v=4"),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 35, maxHeight: 35)
                                .cornerRadius(5)
                        },
                        placeholder: {
                            ProgressView()
                                .frame(maxWidth: 35, maxHeight: 35)
                        }
                    )
                    
                    VStack {
                        Button("Nathan") {
                            UIApplication.shared.open(URL(string: "https://github.com/verygenericname")!)
                        }
                        .font(Font.headline.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Big brainer, made the method")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 13))
                            .foregroundColor(Color.accentColor)
                    }
                }
                
                HStack {
                    AsyncImage (
                        url: URL(string: "https://avatars.githubusercontent.com/u/85764897?v=4"),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 35, maxHeight: 35)
                                .cornerRadius(20)
                        },
                        placeholder: {
                            ProgressView()
                                .frame(maxWidth: 35, maxHeight: 35)
                        }
                    )
                    
                    VStack {
                        Button("haxi0") {
                            UIApplication.shared.open(URL(string: "https://github.com/haxi0")!)
                        }
                        .font(Font.headline.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Made the app, instructions")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 13))
                            .foregroundColor(Color.accentColor)
                    }
                }
                
                HStack {
                    AsyncImage (
                        url: URL(string: "https://avatars.githubusercontent.com/u/87151697?v=4"),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 35, maxHeight: 35)
                                .cornerRadius(20)
                        },
                        placeholder: {
                            ProgressView()
                                .frame(maxWidth: 35, maxHeight: 35)
                        }
                    )
                    
                    VStack {
                        Button("BomberFish") {
                            UIApplication.shared.open(URL(string: "https://github.com/BomberFish")!)
                        }
                        .font(Font.headline.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("ApplicationManager, app icon")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 13))
                            .foregroundColor(Color.accentColor)
                    }
                }
                
                HStack {
                    AsyncImage (
                        url: URL(string: "https://avatars.githubusercontent.com/u/52459150?v=4"),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 35, maxHeight: 35)
                                .cornerRadius(20)
                        },
                        placeholder: {
                            ProgressView()
                                .frame(maxWidth: 35, maxHeight: 35)
                        }
                    )
                    
                    VStack {
                        Button("sourcelocation & Evyrest") {
                            UIApplication.shared.open(URL(string: "https://github.com/sourcelocation/Evyrest/blob/add-license-1/LICENSE")!)
                        }
                        .font(Font.headline.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("TextField++")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 13))
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
    }
}
