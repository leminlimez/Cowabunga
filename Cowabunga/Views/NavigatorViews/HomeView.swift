//
//  HomeView.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

import SwiftUI

struct HomeView: View {
    @State private var versionBuildString: String?
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(key: "DockHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "HomeBarHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "FolderBGHidden", fileType: OverwritingFileTypes.springboard),
        .init(key: "FolderBlurDisabled", fileType: OverwritingFileTypes.springboard),
        .init(key: "SwitcherBlurDisabled", fileType: OverwritingFileTypes.springboard),
        .init(key: "CCModuleBackgroundDisabled", fileType: OverwritingFileTypes.cc),
    ]
    
    @ObservedObject var backgroundController = BackgroundFileUpdaterController.shared
    
    @State private var autoRespring: Bool = UserDefaults.standard.bool(forKey: "AutoRespringOnApply")
    @State private var runInBackground: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    @State private var bgUpdateInterval: Double = UserDefaults.standard.double(forKey: "BackgroundUpdateInterval")
    
    @State private var autoFetchAudio: Bool = UserDefaults.standard.bool(forKey: "AutoFetchAudio")
    @State private var autoFetchLocks: Bool = UserDefaults.standard.bool(forKey: "AutoFetchLocks")
    
    @State var bgUpdateIntervalDisplayTitles: [Double: String] = [
        120.0: "Frequent",
        600.0: "Power Saving"
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        // apply all tweaks button
                        Button("Fix tweaks") {
                            applyTweaks()
                        }
                        .buttonStyle(FullwidthTintedButton(color: .blue))
                        
                        Button("Respring") {
                            respring()
                        }
                        .buttonStyle(FullwidthTintedButton(color: .red))
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                    // auto respring option
                    HStack {
                        Toggle(isOn: $autoRespring) {
                            Text("Auto respring after apply")
                                .minimumScaleFactor(0.5)
                        }.onChange(of: autoRespring) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "AutoRespringOnApply")
                        }
                    }
                } header: {
                    Text("Tweak Options")
                }
                
                Section {
                    // app preferences
                    // background run frequency
                    HStack {
                        Text("Background Update Frequency")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button(bgUpdateIntervalDisplayTitles[bgUpdateInterval] ?? "Error", action: {
                            // create and configure alert controller
                            let alert = UIAlertController(title: "Choose an update option", message: "", preferredStyle: .actionSheet)
                            
                            // create the actions
                            for (t, title) in bgUpdateIntervalDisplayTitles {
                                let newAction = UIAlertAction(title: title, style: .default) { (action) in
                                    // apply the type
                                    bgUpdateInterval = t
                                    // set the default
                                    UserDefaults.standard.set(t, forKey: "BackgroundUpdateInterval")
                                    // update the timer
                                    backgroundController.time = bgUpdateInterval
                                }
                                if bgUpdateInterval == t {
                                    // add a check mark
                                    newAction.setValue(true, forKey: "checked")
                                }
                                alert.addAction(newAction)
                            }
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                                // cancels the action
                            }
                            
                            // add the actions
                            alert.addAction(cancelAction)
                            
                            let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                            // present popover for iPads
                            alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                            alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                            
                            // present the alert
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                        })
                        .foregroundColor(.blue)
                        .padding(.leading, 10)
                    }
                    
                    // run in background toggle
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
                            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                                exit(0)
                            }
                            //BackgroundFileUpdaterController.shared.enabled = new
                        }
                    }
                    
                    // auto fetch audio updates toggle
                    HStack {
                        Toggle(isOn: $autoFetchAudio) {
                            HStack {
                                Text("Auto Update Included Audio")
                                    .minimumScaleFactor(0.5)
                            }
                        }.onChange(of: autoFetchAudio) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "AutoFetchAudio")
                        }
                    }
                    
                    // auto fetch locks updates toggle
                    /*HStack {
                        Toggle(isOn: $autoFetchLocks) {
                            HStack {
                                Text("Auto Update Included Locks")
                                    .minimumScaleFactor(0.5)
                            }
                        }.onChange(of: autoFetchLocks) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "AutoFetchLocks")
                        }
                        .padding(.leading, 10)
                    }*/
                    
                    // button to update included files
                    Button("Update Included Audio", action: {
                        AudioFiles.setup(fetchingNewAudio: true)
                        //LockManager.setup(fetchingNewLocks: true)
                    })
                } header: {
                    Text("Preferences")
                }
                
                Section {
                    // app credits
                    LinkCell(imageName: "leminlimez", url: "https://github.com/leminlimez", title: "leminlimez", contribution: "Main Developer", circle: true)
                    LinkCell(imageName: "sourcelocation", url: "https://github.com/sourcelocation", title: "SourceLocation", contribution: "Co-Developer", circle: true)
                    LinkCell(imageName: "c22dev", url: "https://github.com/c22dev", title: "c22dev", contribution: "Included Audio & Credits", circle: true)
                    LinkCell(imageName: "zhuowei", url: "https://twitter.com/zhuowei/", title: "zhuowei", contribution: "Unsandboxing", circle: true)
                    //LinkCell(imageName: "haxi0", url: "https://github.com/haxi0", title: "haxi0", contribution: "TrollLock", circle: true)
                    LinkCell(imageName: "ginsudev", url: "https://github.com/ginsudev/WDBFontOverwrite", title: "ginsudev", contribution: "Exploit Code", circle: true)
                    LinkCell(imageName: "avangelista", url: "https://github.com/Avangelista", title: "Avangelista", contribution: "Status Bar Mods")
                    LinkCell(imageName: "BomberFish", url: "https://github.com/BomberFish", title: "BomberFish", contribution: "AirPower Audio", circle: true)
                    LinkCell(imageName: "matteozappia", url: "https://github.com/matteozappia", title: "matteozappia", contribution: "Dynamic Island SubTypes", circle: true)
                } header: {
                    Text("Credits")
                }
                
                Section {
                    LinkCell(imageName: "", url: "", title: "Yan.#0001", contribution: "French")
                    LinkCell(imageName: "", url: "", title: "sourcelocation", contribution: "Russian")
                    LinkCell(imageName: "", url: "", title: "Abbyy#2820", contribution: "Polish")
                    LinkCell(imageName: "", url: "", title: "Maxiwee#9333", contribution: "German")
                    LinkCell(imageName: "", url: "", title: "kylak#5621", contribution: "Portuguese")
                    LinkCell(imageName: "", url: "", title: "Skyfall#5572", contribution: "Chinese")
                    LinkCell(imageName: "", url: "", title: "yun#7739", contribution: "Vietnamese")
                    LinkCell(imageName: "", url: "", title: "iwishkem.#3116", contribution: "Turkish")
                } header: {
                    Text("Translators")
                }
                
                Section {
                    
                } header: {
                    Text("Version \(Bundle.main.releaseVersionNumber ?? "UNKNOWN") (\(versionBuildString ?? "Release"))")
                }
            }
            .navigationTitle("Cowabunga")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            backgroundController.setup()
            var isGood = false
            for (t, _) in bgUpdateIntervalDisplayTitles {
                if bgUpdateInterval == t {
                    isGood = true
                    break
                }
            }
            if !isGood {
                // set the default
                UserDefaults.standard.set(120.0, forKey: "BackgroundUpdateInterval")
                bgUpdateInterval = 120.0
            }
            backgroundController.time = bgUpdateInterval
            
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, build != "0" {
                versionBuildString = "Beta \(build)"
            }
        }
    }
    
    func applyTweaks() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIApplication.shared.alert(title: "Applying springboard tweaks...", body: "Please wait", animated: false, withButton: false)
        var failedSB: Bool = false
        // apply the springboard tweaks first
        for option in tweakOptions {
            // get the user defaults
            let value: Bool = UserDefaults.standard.bool(forKey: option.key)
            if value == true {
                print("Applying tweak \"" + option.key + "\"")
                let succeeded = overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, value)
                if succeeded {
                    print("Successfully applied tweak \"" + option.key + "\"")
                } else {
                    print("Failed to apply tweak \"" + option.key + "\"!!!")
                    failedSB = true
                }
            }
        }
        
        UIApplication.shared.change(title: "Applying audio tweaks...", body: "Please wait")
        var failedAudio: Bool = false
        // apply audio tweaks next
        let succeeded = AudioFiles.applyAllAudio()
        if !succeeded {
            failedAudio = true
        }
        
        UIApplication.shared.change(title: "Applying color tweaks...", body: "Please wait")
        if !UserDefaults.standard.bool(forKey: "FolderBGHidden") {
            SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folder)
            SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.libraryFolder)
        }
        if !UserDefaults.standard.bool(forKey: "FolderBlurDisabled") {
            SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folderBG)
        }
        if !UserDefaults.standard.bool(forKey: "SwitcherBlurDisabled") {
            SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.switcher)
        }
        if !UserDefaults.standard.bool(forKey: "DockHidden") {
            SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.dock)
        }
        
        if failedSB && failedAudio {
            UIApplication.shared.dismissAlert(animated: true)
            UIApplication.shared.alert(body: "An error occurred when applying springboard and audio tweaks")
        } else if failedSB {
            UIApplication.shared.dismissAlert(animated: true)
            UIApplication.shared.alert(body: "An error occurred when applying springboard tweaks")
        } else if failedAudio {
            UIApplication.shared.dismissAlert(animated: true)
            UIApplication.shared.alert(body: "Failed to apply audio for: " + AudioFiles.applyFailedMessage + ".")
        } else {
            if autoRespring {
                // auto respring on apply
                UIApplication.shared.change(title: "Respringing...", body: "Please wait")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    respring()
                }
            } else {
                UIApplication.shared.dismissAlert(animated: true)
                UIApplication.shared.alert(title: "Successfully applied tweaks!", body: "Respring to see changes.")
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
                        if imageName != "" {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .cornerRadius(circle ? .infinity : 0)
                .frame(width: 24, height: 24)
                
                VStack {
                    HStack {
                        Button(action: {
                            if url != "" {
                                UIApplication.shared.open(URL(string: url)!)
                            }
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
