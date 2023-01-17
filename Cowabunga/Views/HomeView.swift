//
//  HomeView.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

import SwiftUI

struct HomeView: View {
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(key: "DockHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "HomeBarHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "FolderBGHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "RegionRestrictionsRemoved", fileType: OverwritingFileTypes.region),
        .init(key: "SwitcherBlurDisabled", fileType: OverwritingFileTypes.springboard),
        .init(key: "ShortcutBannerDisabled", fileType: OverwritingFileTypes.plist),
    ]
    
    // list of audio options
    @State var audioOptions: [AudioFiles.SoundEffect] = [
        AudioFiles.SoundEffect.charging,
        AudioFiles.SoundEffect.lock,
        AudioFiles.SoundEffect.notification,
        AudioFiles.SoundEffect.screenshot
    ]
    
    @State private var autoRespring: Bool = UserDefaults.standard.bool(forKey: "AutoRespringOnApply")
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // auto respring option
                    HStack {
                        /*Image(systemName: option.imageName.wrappedValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)*/
                        
                        Toggle(isOn: $autoRespring) {
                            Text("Auto respring after apply")
                                .minimumScaleFactor(0.5)
                        }.onChange(of: autoRespring) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "AutoRespringOnApply")
                        }
                        .padding(.leading, 10)
                    }
                    
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
                    // app preferences
                } header: {
                    Text("Preferences")
                }
                
                Section {
                    // app credits
                } header: {
                    Text("Credits")
                }
            }
            .navigationTitle("Cowabunga")
        }
    }
    
    func applyTweaks() {
        var failedSB: Bool = false
        // apply the springboard tweaks first
        for option in tweakOptions {
            // get the user defaults
            let value: Bool = UserDefaults.standard.bool(forKey: option.key)
            if value == true {
                print("Applying tweak \"" + option.key + "\"")
                overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, value) { succeeded in
                    if succeeded {
                        print("Successfully applied tweak \"" + option.key + "\"")
                    } else {
                        print("Failed to apply tweak \"" + option.key + "\"!!!")
                        failedSB = true
                    }
                }
            }
        }
        
        var failedAudio: Bool = false
        // apply audio tweaks next
        for option in audioOptions {
            // get the user defaults
            // apply if not default
            let currentAudio: String = UserDefaults.standard.string(forKey: option.rawValue+"_Applied") ?? "Default"
            if currentAudio != "Default" {
                overwriteFile(typeOfFile: OverwritingFileTypes.audio, fileIdentifier: option.rawValue, currentAudio) { succeeded in
                    if succeeded {
                        print("successfully applied audio for " + option.rawValue)
                    } else {
                        failedAudio = true
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            if failedSB && failedAudio {
                UIApplication.shared.alert(body: "An error occurred when applying springboard and audio tweaks")
            } else if failedSB {
                UIApplication.shared.alert(body: "An error occurred when applying springboard tweaks")
            } else if failedAudio {
                UIApplication.shared.alert(body: "An error occurred when applying audio tweaks")
            } else {
                if autoRespring {
                    // auto respring on apply
                    respring()
                } else {
                    UIApplication.shared.alert(title: "Successfully applied tweaks!", body: "Respring to see changes.")
                }
            }
        }
    }
    
    struct GeneralOption: Identifiable {
        var id = UUID()
        var key: String
        var fileType: OverwritingFileTypes
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
