//
//  ThemesView.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import MacDirtyCowSwift
import SwiftUI

@available(iOS 15, *)
struct ThemesView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var isImporting = false
    @State var isSelectingCustomIcons = false
    @State var showsSettings = false
    @State var easterEgg = false
    
    @State var wallpaper: UIImage?
    @State var defaultWallpaper = false
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    
    @State var themes: [Theme] = []
    
    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    if themes.count == 0 {
                        Text("No themes found. Download themes in the Explore tab,\nor import them using the button in the top right corner (Themes have to contain icons in the format of <id>.png).")
                            .padding()
                            .background(Color(uiColor14: .secondarySystemBackground))
                            .multilineTextAlignment(.center)
                            .cornerRadius(16)
                            .font(.footnote)
                            .foregroundColor(Color(uiColor14: .secondaryLabel))
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridItemLayout, spacing: 8) {
                                ForEach(themes, id: \.name) { theme in
                                    ThemeView(theme: theme, wallpaper: wallpaper!, defaultWallpaper: defaultWallpaper)
                                        .contextMenu {
                                            Button {
                                                
                                                let alert = UIAlertController(title: NSLocalizedString("Rename theme", comment: "Entering new theme name"), message: "", preferredStyle: .alert)
                                                alert.addTextField { (textField) in
                                                    textField.placeholder = NSLocalizedString("New theme name", comment: "")
                                                }
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .default) { (action) in
                                                    do {
                                                        guard let name = alert.textFields![0].text else { return }
                                                        try themeManager.renameImportedTheme(id: theme.id, newName: name)
                                                    } catch {
                                                        UIApplication.shared.alert(body: error.localizedDescription)
                                                    }
                                                })
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                                            } label: {
                                                Label("Rename", systemImage: "pencil")
                                            }
                                            
                                            Button {
                                                themes.removeAll { theme1 in theme1.id == theme.id }
                                                themeManager.themes = themes
                                                do {
                                                    try themeManager.removeImportedTheme(theme: theme)
                                                } catch {
                                                    UIApplication.shared.alert(body: error.localizedDescription)
                                                }
                                            } label: {
                                                Label("Remove theme", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(4)
                            
                            VStack {
                                HStack {
                                    VStack {
                                        Text(easterEgg ? "Wait, it's all TrollTools?" : "Cowabunga \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                                            .multilineTextAlignment(.center)
                                        Text(easterEgg ? "Always has been" : "Download themes in Themes tab.")
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(10)
                                    .background(Color(uiColor14: .secondarySystemBackground))
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        easterEgg.toggle()
                                        Haptic.shared.notify(.success)
                                    }
                                    VStack {
                                        HStack {
                                            Text("Alternatives")
                                                .font(.headline)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.7)
                                                .padding(4)

                                            Text("· \(themeManager.iconOverrides.count)")
                                                .font(.headline)
                                                .foregroundColor(Color.secondary)
                                            Spacer()
                                        }
                                        NavigationLink(destination: IconOverridesView()) {
                                            Text("Change")
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .background(Color(uiColor14: UIColor.tertiarySystemBackground))
                                                .cornerRadius(8)
                                                .foregroundColor(.init(uiColor14: .label))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color(uiColor14: .secondarySystemBackground))
                                    .cornerRadius(16)
                                }
                                
                                
                                Button("Rebuild Icon Cache") {
                                    do {
                                        UIApplication.shared.alert(title: "Scheduling a rebuild", body: "", withButton: false)
                                        try rebuildIconCache()
                                    } catch { UIApplication.shared.alert(body: error.localizedDescription) }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(10)
                                .background(Color(uiColor14: .secondarySystemBackground))
                                .cornerRadius(16)
                            }
                            .padding(.bottom, 80)
                        }
                        .padding(.horizontal, 6)
                    }
                }.padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isImporting = true
                        }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive, action: {
                            UIApplication.shared.confirmAlert(title: "Full reset", body: "All app icons will be reverted to their original appearance. Are you sure you want to continue? (Reboot may be required)", onOK: {
                                themeManager.preferedThemes = []
                                applyChanges()
                            }, noCancel: false)
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
                .navigationTitle("Themes")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                wallpaper = UIImage(named: "wallpaper")!
                defaultWallpaper = true
                
//                // Old version check
//                var shouldReset = false
//                for themeURL in (try? FileManager.default.contentsOfDirectory(at: themesDir, includingPropertiesForKeys: nil)) ?? [] {
//                    for icons in (try? FileManager.default.contentsOfDirectory(at: themeURL, includingPropertiesForKeys: nil)) ?? [] {
//                        if icons.lastPathComponent == "IconBundles" {
//                            shouldReset = true
//                            break
//                        }
//                    }
//                }
//                if shouldReset {
//                    UIApplication.shared.confirmAlert(title: "Theme reset required", body: "Due to major changes to the engine, a reset of themes is required.", onOK: {
//                        try? FileManager.default.removeItem(at: themesDir)
//                        UserDefaults.standard.set(nil, forKey: "themes")
//                        UserDefaults.standard.set(nil, forKey: "currentThemeIDs")
//                        removeThemes(removeWebClips: false)
//                    }, noCancel: true)
//                }
                
                themes = themeManager.themes
            }
            
            VStack {
                Spacer()
                Button(action: {
                    applyChanges()
                }) {
                    if themes.count > 0 {
                        Text("Apply themes")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of file. Did you select it?"); return }
            if themes.contains(where: { t in
                t.name == url.deletingPathExtension().lastPathComponent
            }) {
                UIApplication.shared.alert(body: "Theme with the name \(url.deletingPathExtension().lastPathComponent) already exists. Please rename the folder.")
                return
            }
            do {
                let theme = try themeManager.importTheme(from: url)
                themes.append(theme)
                themeManager.themes = themes
            } catch { UIApplication.shared.alert(body: error.localizedDescription) }
        }
    }
    func applyChanges() {
        func apply() {
            let timeStart = Date()
            DispatchQueue.global(qos: .userInitiated).async {
                UIApplication.shared.alert(title: "Starting", body: "Please wait", animated: false, withButton: false)
                do {
                    try themeManager.applyChanges(progress: { str in
                        UIApplication.shared.change(title: "In progress", body: str)
                    })
                    
                    UIApplication.shared.change(title: "In progress", body: "Scheduling icon cache reset...")
                    
//                    let iconservicesagentURL = URL(fileURLWithPath: "/System/Library/CoreServices/iconservicesagent")
//                    var byteArray = [UInt8](try! Data(contentsOf: iconservicesagentURL))
//
//
//                    let findBytes: [UInt8]    = [UInt8]("/System/Library/CoreServices/SystemVersion.plist".data(using: .utf8)!)
//                    let replaceBytes: [UInt8] = [UInt8]("/var/mobile/.DO-NOT-DELETE-Cowabunga/dummy.plist".data(using: .utf8)!)
//
//                    var startIndex = 0
//                    while startIndex <= byteArray.count - findBytes.count {
//                        let endIndex = startIndex + findBytes.count
//                        let subArray = Array(byteArray[startIndex..<endIndex])
//
//                        if subArray == findBytes {
//                            byteArray.replaceSubrange(startIndex..<endIndex, with: replaceBytes)
//                            startIndex += replaceBytes.count
//                        } else {
//                            startIndex += 1
//                        }
//                    }
//                    let newData = Data(byteArray)
//
//                    print(MDC.overwriteFile(at: iconservicesagentURL.path, with: newData))
                    let lengthOfOldVersion = (try getValueInSystemVersionPlist(key: "ProductBuildVersion") as? String)?.count ?? 6
                    let oldVersion = try setValueInSystemVersionPlist(key: "ProductBuildVersion", value: "\(Int.random(in: (10^^(lengthOfOldVersion - 1))...(10^^lengthOfOldVersion - 1)))")
//
                    xpc_crash("com.apple.iconservices")
//
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        do {
                            let _ = try setValueInSystemVersionPlist(key: "ProductBuildVersion", value: oldVersion)
                        } catch {
                            UIApplication.shared.change(body: error.localizedDescription)

                        }

                        UIApplication.shared.dismissAlert(animated: false)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            UIApplication.shared.confirmAlert(title: "Success", body: "⚠️⬇ PLEASE READ ⬇⚠️\n\n After the phone resprings, please *reopen Cowabunga* to fix apps not functioning properly\n\nVERY IMPORTANT: If you see the apple logo and progress bar, do not worry, your device is fine. PLEASE DO NOT ATTEMPT TO FORCE REBOOT IT.\n\nElapsed time: \(Double(Int(-timeStart.timeIntervalSinceNow * 100.0)) / 100.0)s", confirmTitle: NSLocalizedString("Understood, Respring", comment: "Shown after successful theme set."), onOK: {
                                    respring()
                            }, noCancel: true)
                        })
                    })
                } catch { UIApplication.shared.change(body: error.localizedDescription) }
            }
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred(); apply()
    }
    
    
    func rebuildIconCache() throws {
        let lengthOfOldVersion = (try getValueInSystemVersionPlist(key: "ProductBuildVersion") as? String)?.count ?? 6
        let oldVersion = try setValueInSystemVersionPlist(key: "ProductBuildVersion", value: "\(lengthOfOldVersion == 6 ? Int.random(in: 100000...999999) : Int.random(in: 10000...99999))")
//
        xpc_crash("com.apple.iconservices")
//
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            do {
                let _ = try setValueInSystemVersionPlist(key: "ProductBuildVersion", value: oldVersion)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                    respring()
                })
            } catch {
                UIApplication.shared.change(body: error.localizedDescription)

            }
        })
    }
}


@available(iOS 15, *)
struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
