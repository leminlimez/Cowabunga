//
//  HomeView.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

import SwiftUI

struct HomeView: View {
    @State private var versionBuild: String = " (beta 5)"
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(key: "DockHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "HomeBarHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "FolderBGHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "FolderBlurDisabled", fileType: OverwritingFileTypes.springboard),
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
    
    @ObservedObject var backgroundController = BackgroundFileUpdaterController.shared
    
    @State private var autoRespring: Bool = UserDefaults.standard.bool(forKey: "AutoRespringOnApply")
    @State private var runInBackground: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    
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
                    HStack {
                        Toggle(isOn: $runInBackground) {
                            HStack {
                                Text("Run in background")
                                    .minimumScaleFactor(0.5)
                                /*Button(action: {
                                    UIApplication.shared.alert(title: "Run in Background", body: "Use location services to keep the dock and folder background hidden. Location Services must be set to ALWAYS")
                                }) {
                                    Image(systemName: "info.circle")
                                }*/
                            }
                        }.onChange(of: runInBackground) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "BackgroundApply")
                            if new == false {
                                ApplicationMonitor.shared.stop()
                            }
                            exit(0)
                            //BackgroundFileUpdaterController.shared.enabled = new
                        }
                        .padding(.leading, 10)
                    }
                } header: {
                    Text("Preferences")
                }
                
                Section {
                    // app credits
                    LinkCell(imageName: "leminlimez", url: "https://github.com/leminlimez", title: "leminlimez", contribution: "Main Developer", circle: true)
                    LinkCell(imageName: "sourcelocation", url: "https://github.com/sourcelocation", title: "SourceLocation", contribution: "SpringBoard Grid UI &  Background Running", circle: true)
                    LinkCell(imageName: "c22dev", url: "https://github.com/c22dev", title: "c22dev", contribution: "Audios, Audio Conversion, & Credits", circle: true)
                    LinkCell(imageName: "ginsudev", url: "https://github.com/ginsudev/WDBFontOverwrite", title: "ginsudev", contribution: "Exploit Code", circle: true)
                    LinkCell(imageName: "BomberFish", url: "https://github.com/BomberFish", title: "BomberFish", contribution: "AirPower Audio", circle: true)
                    LinkCell(imageName: "matteozappia", url: "https://github.com/matteozappia", title: "matteozappia", contribution: "Dynamic Island SubTypes", circle: true)
                } header: {
                    Text("Credits")
                }
                
                Section {
                    
                } header: {
                    Text("Version " + (Bundle.main.releaseVersionNumber ?? "UNKNOWN") + versionBuild)
                }
            }
            .navigationTitle("Cowabunga")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            backgroundController.setup()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
    
    struct LinkCell: View {
        var imageName: String
        var url: String
        var title: String
        var contribution: String
        var systemImage: Bool = false
        var circle: Bool = false
        
        var body: some View {
            HStack(alignment: .center) {
                Group {
                    if systemImage {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .cornerRadius(circle ? .infinity : 0)
                .frame(width: 24, height: 24)
                VStack {
                    HStack {
                        Button(action: {
                            UIApplication.shared.open(URL(string: url)!)
                        }) {
                            Text(title)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 6)
                        Spacer()
                    }
                    HStack {
                        Text(contribution)
                            .padding(.horizontal, 6)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .foregroundColor(.blue)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
