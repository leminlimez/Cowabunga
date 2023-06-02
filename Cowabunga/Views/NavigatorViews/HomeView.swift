//
//  HomeView.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

import SwiftUI

struct HomeView: View {
    // lazyvgrid
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100))]
    
    @State private var versionBuildString: String?
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(key: "Dock", fileType: OverwritingFileTypes.springboard, sbType: .dock),
        .init(key: "HomeBar", fileType: OverwritingFileTypes.springboard),
        .init(key: "FolderBG", fileType: OverwritingFileTypes.springboard, sbType: .folder),
        .init(key: "FolderBlur", fileType: OverwritingFileTypes.springboard, sbType: .folderBG),
        .init(key: "Switcher", fileType: OverwritingFileTypes.springboard, sbType: .switcher),
        .init(key: "CCBG", fileType: .springboard, sbType: .moduleBG),
        .init(key: "CCModuleBG", fileType: OverwritingFileTypes.cc, sbType: .module),
        .init(key: "PodBG", fileType: OverwritingFileTypes.springboard, sbType: .libraryFolder),
        .init(key: "NotifBG", fileType: OverwritingFileTypes.springboard, sbType: .notif),
        .init(key: "NotifShadow", fileType: .springboard, sbType: .notifShadow)
    ]
    
    struct Translator: Identifiable {
        var id = UUID()
        var names: String
        var contribution: String
    }
    
    // list of translators
    @State private var translators: [Translator] = [
        .init(names: "Zaalhir#1288 & Panwato#9764", contribution: "🇪🇸 Spanish"),
        .init(names: "c22dev", contribution: "🇫🇷 French"),
        .init(names: "Mattia#6297", contribution: "🇮🇹 Italian"),
        .init(names: "Abbyy#2820", contribution: "🇵🇱 Polish"),
        .init(names: "Maxiwee#9333", contribution: "🇩🇪 German"),
        .init(names: "Eevee#0094", contribution: "🇷🇺 Russian"),
        .init(names: "Callz#1352", contribution: "🇸🇪 Swedish"),
        .init(names: "kylak#5621", contribution: "🇧🇷 Portuguese"),
        .init(names: "Skyfall#5572 & Chihaodong", contribution: "🇨🇳 Chinese (China Mainland)"),
        .init(names: "@CySxL & CydaiDEV#4450", contribution: "🇹🇼 Traditional Chinese (Taiwan)"),
        .init(names: "mystical#2343 & rahsey#2222", contribution: "🇻🇳 Vietnamese"),
        .init(names: "crimeboss#6704 & meliherdem#0001", contribution: "🇹🇷 Turkish"),
        .init(names: "TaekyungAncal#7857", contribution: "🇰🇷 Korean"),
        .init(names: "Aru Pro#2789", contribution: "🇦🇪 Arabic"),
        .init(names: "EPOS#0646", contribution: "🇳🇱 Dutch")
    ]
    
    @ObservedObject var backgroundController = BackgroundFileUpdaterController.shared
    @StateObject var appIconViewModel = ChangeAppIconViewModel()
    
    @ObservedObject var patreonAPI = PatreonAPI.shared
    @State private var patrons: [Patron] = []
    
    @State private var autoRespring: Bool = UserDefaults.standard.bool(forKey: "AutoRespringOnApply")
    
    @State private var runInBackground: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    @State private var bgUpdateInterval: Double = UserDefaults.standard.double(forKey: "BackgroundUpdateInterval")
    @State var bgTasksVisible: Bool = false
    
    @State private var respringType = UserDefaults.standard.string(forKey: "RespringType")
    @State private var customOperationsAuthorName = UserDefaults.standard.string(forKey: "CustomOperationsAuthorName")
    @State private var autoFetchAudio: Bool = UserDefaults.standard.bool(forKey: "AutoFetchAudio")
    @State private var autoFetchLocks: Bool = UserDefaults.standard.bool(forKey: "AutoFetchLocks")
    @State private var lockPrefs: String = UserDefaults.standard.string(forKey: "LockPrefs") ?? LockManager.globalLockPaths[0]
    private var deviceType = UIDevice().machineName
    
    @State var bgUpdateIntervalDisplayTitles: [Double: String] = [
        120.0: NSLocalizedString("Frequent", comment: "Frequent"),
        600.0: NSLocalizedString("Default", comment: "Default"),
        1800.0: NSLocalizedString("Power Saving", comment: "Power Saving")
    ]
    
    @State private var dateFormat: String = UserDefaults.standard.string(forKey: "DateFormat") ?? "MM/dd"
    
    private var dateFormats: [String] = [
        "MM/dd",
        "MM/dd/yyyy",
        "MMM dd",
        "MMM dd yyyy",
        
        "dd/MM",
        "dd/MM/yyyy",
        "dd MMM",
        "dd MMM yyyy",
        
        "EEE, MMM dd",
        "EEEE"
    ]
    
    private var dateFormattingExamples: [String: String] = [
        "MM/dd": "03/20",
        "MM/dd/yyyy": "03/20/2023",
        "MMM dd": "Mar 20",
        "MMM dd yyyy": "Mar 20 2023",
        
        "dd/MM": "20/03",
        "dd/MM/yyyy": "20/03/2023",
        "dd MMM": "20 Mar",
        "dd MMM yyyy": "20 Mar 2023",
        
        "EEE, MMM dd": "Mon, Mar 20",
        "EEEE": "Monday"
    ]
    
    var body: some View {
        NavigationView {
            List {
                // MARK: App Version
                Section {
                    
                } header: {
                    Label("Version \(Bundle.main.releaseVersionNumber ?? "UNKNOWN") (\(versionBuildString ?? "Release"))", systemImage: "info")
                }
                
                // MARK: Tweak Options
                Section {
                    VStack {
                        // apply all tweaks button
                        HStack {
                            Button("Fix tweaks") {
                                applyTweaks()
                            }
                            .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                            Button {
                                UIApplication.shared.alert(title: NSLocalizedString("Info", comment: "fix tweaks info header"), body: NSLocalizedString("Applies all tweaks which were applied before.", comment: "fix tweaks info"))
                            } label: {
                                Image(systemName: "info")
                            }
                            .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                        }
                        
                        HStack {
                            Button("Respring") {
                                respring()
                            }
                            .buttonStyle(TintedButton(color: .red, fullwidth: true))
                            Button {
                                UIApplication.shared.alert(title: NSLocalizedString("Info", comment: "respring info header"), body: NSLocalizedString("Respring is an action that allows restarting your Home Screen without rebooting your device.", comment: "respring info"))
                            } label: {
                                Image(systemName: "info")
                            }
                            .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                        }
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
                    Label("Tweak Options", systemImage: "hammer")
                }
                
                // MARK: Background Applying Options
                Section {
                    // MARK: Background Run Frequency
                    HStack {
                        Text("Update Frequency")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button(bgUpdateIntervalDisplayTitles[bgUpdateInterval] ?? "Error", action: {
                            // create and configure alert controller
                            let alert = UIAlertController(title: NSLocalizedString("Choose an update option", comment: "Title for choosing background update interval"), message: "", preferredStyle: .actionSheet)
                            
                            // create the actions
                            for (t, title) in bgUpdateIntervalDisplayTitles.sorted(by: { $0.0 < $1.0 }) {
                                let newAction = UIAlertAction(title: title + " (" + NSLocalizedString("Every \(Int(t/60)) Minutes", comment: "The option title for background frequency") + ")", style: .default) { (action) in
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
                            
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
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
                    
                    // MARK: Run in Background Toggle
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
                            var newWord: String = "Enabled"
                            if new == false {
                                newWord = "Disabled"
                                ApplicationMonitor.shared.stop()
                            }
                            UIApplication.shared.confirmAlert(title: "Background Applying \(newWord)", body: "The app needs to restart to apply the change.", onOK: {
                                exitGracefully()
                            }, noCancel: true)
                            //BackgroundFileUpdaterController.shared.enabled = new
                        }
                    }
                    
                    // MARK: Manage Background Tasks
                    if runInBackground {
                        Button("Manage Background Tasks", action: {
                            bgTasksVisible.toggle()
                        })
                    }
                } header: {
                    Label("Background Applying", systemImage: "photo")
                }
                
                Section {
                    // app preferences
                    // MARK: Respring Type
                    HStack {
                        Text("Respring Type")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button(respringType ?? "Frontboard", action: {
                            // create and configure alert controller
                            let alert = UIAlertController(title: NSLocalizedString("Choose a respring type", comment: "Title for respring type"), message: NSLocalizedString("Try out each respring type and determine which works best for your needs.", comment: "Description for respring type"), preferredStyle: .actionSheet)
                            
                            // create the actions
                            let frontboardAction = UIAlertAction(title: "Frontboard", style: .default) { (action) in
                                // apply the type
                                respringType = "Frontboard"
                                // set the default
                                UserDefaults.standard.set("Frontboard", forKey: "RespringType")
                            }
                            let backboardAction = UIAlertAction(title: "Backboard", style: .default) { (action) in
                                // apply the type
                                respringType = "Backboard"
                                // set the default
                                UserDefaults.standard.set("Backboard", forKey: "RespringType")
                            }
                            
                            if respringType == "Backboard" {
                                backboardAction.setValue(true, forKey: "checked")
                            } else {
                                frontboardAction.setValue(true, forKey: "checked")
                            }
                            alert.addAction(frontboardAction)
                            alert.addAction(backboardAction)
                            
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
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
                    
                    // MARK: Custom Operations Author Name
                    HStack {
                        Text("Custom Operations Author Name")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button(customOperationsAuthorName ?? "Enter Name", action: {
                            let defaults = UserDefaults.standard
                            // create and configure alert controller
                            let alert = UIAlertController(title: NSLocalizedString("Enter Author Name", comment: "Header for inputting custom operations author name"), message: NSLocalizedString("This is the name that your exported operations will be attached to.", comment: "Footer for inputting custom operations author name"), preferredStyle: .alert)
                            // bring up the text prompt
                            alert.addTextField { (textField) in
                                textField.placeholder = "Enter Name"
                                textField.text = defaults.string(forKey: "CustomOperationsAuthorName") ?? ""
                            }
                            
                            // buttons
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Apply", comment: ""), style: .default) { (action) in
                                // set the version
                                let newAuthor: String = alert.textFields?[0].text! ?? ""
                                if newAuthor == "" {
                                    // reset the author name
                                    defaults.removeObject(forKey: "CustomOperationsAuthorName")
                                    customOperationsAuthorName = nil
                                } else {
                                   // apply the author name
                                    defaults.set(newAuthor, forKey: "CustomOperationsAuthorName")
                                    customOperationsAuthorName = newAuthor
                                }
                            })
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                // cancel the process
                            })
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                        })
                        .foregroundColor(.blue)
                        .padding(.leading, 10)
                    }
                    
                    // MARK: Lock Type Prefs
                    if LockManager.deviceLockPath[deviceType] != nil {
                        HStack {
                            Text("Lock Type")
                                .minimumScaleFactor(0.5)
                            
                            Spacer()
                            
                            Button(lockPrefs, action: {
                                // create and configure alert controller
                                let alert = UIAlertController(title: NSLocalizedString("Choose a lock preference", comment: "Title for lock preference"), message: NSLocalizedString("If the custom lock does not apply for you, try another option.", comment: "Description for lock preference"), preferredStyle: .actionSheet)
                                let devModel = UIDevice().machineName
                                
                                // create the actions
                                for (_, title) in LockManager.globalLockPaths.enumerated() {
                                    var rec: String = ""
                                    if LockManager.deviceLockPath[devModel] != nil && LockManager.deviceLockPath[devModel]! == title {
                                        rec = " " + NSLocalizedString("(Recommended)", comment: "Recommended lock type")
                                    }
                                    
                                    let newAction = UIAlertAction(title: title+rec, style: .default) { (action) in
                                        // apply the type
                                        lockPrefs = title
                                        // set the default
                                        UserDefaults.standard.set(title, forKey: "LockPrefs")
                                    }
                                    if lockPrefs == title {
                                        // add a check mark if selected
                                        newAction.setValue(true, forKey: "checked")
                                    }
                                    alert.addAction(newAction)
                                }
                                
                                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
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
                    }
                    
                    // MARK: Date Format
                    HStack {
                        Text("Date Format")
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Button(action: {
                            showDateFormatPopup()
                        }) {
                            Text(dateFormat)
                                .foregroundColor(.blue)
                                .padding(.leading, 10)
                        }
                    }
                    // MARK: Apply Date
                    Button(action: {
                        createStatusBarDateTag()
                    }) {
                        Text("Update Status Bar Date")
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
                    
                    // button to update included files
                    Button("Update Included Audio", action: {
                        AudioFiles.setup(fetchingNewAudio: true)
                        //LockManager.setup(fetchingNewLocks: true)
                    })
                    
                    // app icon changer
                    NavigationLink(destination: ChangeAppIconView()) {
                        HStack {
                            Image(uiImage: appIconViewModel.selectedAppIcon.preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                                .frame(width: 60, height: 60)
                                .padding(.trailing, 10)
                            Text("Cowabunga App Icon")
                        }
                    }
                } header: {
                    Label("Preferences", systemImage: "gearshape")
                }
                
                // MARK: App Credits
                Section {
                    // app credits
                    LinkCell(imageName: "leminlimez", url: "https://github.com/leminlimez", title: "leminlimez", contribution: NSLocalizedString("Main Developer", comment: "leminlimez's contribution"), circle: true)
                    LinkCell(imageName: "sourcelocation", url: "https://github.com/sourcelocation", title: "sourcelocation", contribution: NSLocalizedString("Icon Theming, Explore Page", comment: "sourcelocation's contribution"), circle: true)
                    LinkCell(imageName: "BomberFish", url: "https://github.com/BomberFish", title: "BomberFish", contribution: NSLocalizedString("Whitelist, Freeload, AirPower Audio, Various fixes", comment: "BomberFish's contribution"), circle: true)
                    LinkCell(imageName: "c22dev", url: "https://github.com/c22dev", title: "c22dev", contribution: NSLocalizedString("ScreenTime Remover, Included Audio, Credits, and Card Changer", comment: "c22dev's contribution"), circle: true)
                    LinkCell(imageName: "zhuowei", url: "https://twitter.com/zhuowei/", title: "zhuowei", contribution: NSLocalizedString("Unsandboxing, installd patch", comment: "zhuowei's contribution"), circle: true)
                    LinkCell(imageName: "haxi0", url: "https://github.com/haxi0", title: "haxi0", contribution: "TrollLock & DirtyJIT", circle: true)
                    LinkCell(imageName: "Nathan", url: "https://github.com/verygenericname", title: "Nathan", contribution: "DirtyJIT Implementation", circle: true)
                    LinkCell(imageName: "ginsudev", url: "https://github.com/ginsudev/WDBFontOverwrite", title: "ginsudev", contribution: NSLocalizedString("Exploit Code", comment: "ginsudev's contribution") + ", WDBFontOverwrite", circle: true)
                    LinkCell(imageName: "avangelista", url: "https://github.com/Avangelista", title: "Avangelista", contribution: "StatusMagic", circle: true)
                    LinkCell(imageName: "matteozappia", url: "https://github.com/matteozappia", title: "matteozappia", contribution: NSLocalizedString("Dynamic Island SubTypes", comment: "matteozappia's contribution"), circle: true)
                } header: {
                    Label("Credits", systemImage: "wrench.and.screwdriver")
                }
                
                // MARK: Translator Credits
                Section {
                    ForEach(translators) { translator in
                        LinkCell(imageName: "", url: "", title: translator.names, contribution: translator.contribution)
                    }
                } header: {
                    Label("Translators", systemImage: "character.bubble")
                }
                
                // MARK: Patreon Supporters
                if patrons.count > 0 {
                    Section {
                        LazyVGrid(columns: gridItemLayout) {
                            ForEach(patrons) { patron in
                                HStack {
                                    Spacer()
                                    Text(patron.name)
                                        .fontWeight(.bold)
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    } header: {
                        Label("Patreon Supporters", systemImage: "heart")
                    }
                }
            }
            .navigationTitle("Cowabunga")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            backgroundController.setup()
            backgroundController.time = bgUpdateInterval
            
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, build != "0" {
                versionBuildString = "Beta \(build)"
            }
            
            // add the patreon supporters
            loadPatrons()
        }
        .sheet(isPresented: $bgTasksVisible) {
            BackgroundEnablerView(isVisible: $bgTasksVisible)
        }
    }
    
    func loadPatrons() {
        Task {
            do {
                patrons = try await patreonAPI.fetchPatrons()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func showDateFormatPopup() {
        // create and configure alert controller
        let alert = UIAlertController(title: "Choose a date format", message: "", preferredStyle: .actionSheet)
        
        // create the actions
        for f in dateFormats {
            let newAction = UIAlertAction(title: "\(f) (\(dateFormattingExamples[f] ?? "Error"))", style: .default) { (action) in
                // apply the format
                UserDefaults.standard.set(f, forKey: "DateFormat")
                dateFormat = f
            }
            if dateFormat == f {
                // add a check mark
                newAction.setValue(true, forKey: "checked")
            }
            alert.addAction(newAction)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
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
    }
    
    func applyTweaks() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIApplication.shared.alert(title: "Applying springboard tweaks...", body: "Please wait", animated: false, withButton: false)
        var failedSB: Bool = false
        // apply the springboard tweaks first
        for option in tweakOptions {
            // get the user defaults
            let value: String = UserDefaults.standard.string(forKey: option.key) ?? "Visible"
            if value == "Color" || value == "Blur" || value == "Disabled" {
                print("Applying tweak \"" + option.key + "\"")
                var succeeded = false
                print(value)
                if option.sbType != nil {
                    SpringboardColorManager.applyColor(forType: option.sbType!)
                    succeeded = true
                } else {
                    succeeded = overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, true)
                }
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
        
        // apply custom operations
        UIApplication.shared.change(title: "Applying custom operations...", body: "Please wait")
        do {
            try AdvancedManager.applyOperations(background: false)
        } catch {
            print(error.localizedDescription)
        }
        
        // apply the settings tweak
        do {
            try SettingsCustomizerManager.apply()
        } catch {
            print(error.localizedDescription)
        }
        
        if UserDefaults.standard.string(forKey: "CurrentLock") ?? "Default" != "Default" {
            let lockName: String = UserDefaults.standard.string(forKey: "CurrentLock")!
            print("applying lock")
            let _ = LockManager.applyLock(lockName: lockName)
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
        var sbType: SpringboardColorManager.SpringboardType?
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
