//
//  ThemesView.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import SwiftUI

struct ThemesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isImporting = false
    @State var isSelectingCustomIcons = false
    @State var showsSettings = false
    
    @State var wallpaper: UIImage?
    @State var defaultWallpaper = false
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    
    @State var themes: [Theme] = []
    
    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    if themes.count == 0 {
                        Text("No themes imported. \nImport them using the button in the top right corner (Themes have to contain icons in the format of <id>.png).")
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
                            
                            HStack {
                                VStack {
                                    Text("TrollTools \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                                    Text("Made by @sourcelocation.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(10)
                                .background(Color(uiColor14: .secondarySystemBackground))
                                .cornerRadius(16)
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
                            .padding(.bottom, 80)
                        }
                        .padding(.horizontal, 6)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isImporting = true
                        }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            UIApplication.shared.confirmAlert(title: "Full reset", body: "All app icons will be reverted to their original appearance and WebClips will be deleted. Are you sure you want to continue?", onOK: {
                                removeThemes(removeWebClips: true)
                            }, noCancel: false)
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                        }
                    }
                }
                .navigationTitle("Themes")
                .navigationBarTitleTextColor(Color(uiColor14: .label))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                wallpaper = WallpaperGetter.homescreen()
                if wallpaper == nil {
                    wallpaper = UIImage(named: "wallpaper")!
                    defaultWallpaper = true
                }
                
                // Old version check
                var shouldReset = false
                remLog(themesDir)
                for themeURL in (try? FileManager.default.contentsOfDirectory(at: themesDir, includingPropertiesForKeys: nil)) ?? [] {
                    remLog(themeURL)
                    for icons in (try? FileManager.default.contentsOfDirectory(at: themeURL, includingPropertiesForKeys: nil)) ?? [] {
                        remLog(icons)
                        if icons.lastPathComponent == "IconBundles" {
                            shouldReset = true
                            break
                        }
                    }
                }
                if shouldReset {
                    UIApplication.shared.confirmAlert(title: "Theme reset required", body: "Due to major changes to the engine, a reset of themes is required.", onOK: {
                        try? FileManager.default.removeItem(at: themesDir)
                        UserDefaults.standard.set(nil, forKey: "themes")
                        UserDefaults.standard.set(nil, forKey: "currentThemeIDs")
                        removeThemes(removeWebClips: false)
                    }, noCancel: true)
                }
                
                themes = themeManager.themes
            }
            
            VStack {
                Spacer()
                Button(action: {
                    applyChanges()
                }) {
                    if themes.count > 0 {
                        Text("Apply changes")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding()
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
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    UIApplication.shared.change(title: "Rebuilding Icon Cache...", body: "Device will respring after rebuild\n\nElapsed time: \(Double(Int(-timeStart.timeIntervalSinceNow * 100.0)) / 100.0)s")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        try! RootHelper.rebuildIconCache()
                    })
                } catch { UIApplication.shared.change(body: error.localizedDescription) }
            }
        }
        var found = false
        for app in LSApplicationWorkspace.default().allApplications() ?? [] {
            if FileManager.default.fileExists(atPath: app.bundleURL.appendingPathComponent("bak.car").path) {
                if !UserDefaults.standard.bool(forKey: "readAltAppsWarning") {
                    found = true
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    UIApplication.shared.confirmAlert(title: "Mugunghwa installed - PLEASE READ.", body: "It seems you've used other theming engines on this device. It is highly recommended resetting all their options to default values and removing the app.", onOK: { UserDefaults.standard.set(true, forKey: "readAltAppsWarning"); apply() }, noCancel: false)
                    break
                }
            }
        }
        if !found {
            UIImpactFeedbackGenerator(style: .light).impactOccurred(); apply()
        }
    }
    func removeThemes(removeWebClips: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIApplication.shared.alert(title: "Starting", body: "Please wait", animated: false, withButton: false)
            try? themeManager.removeCurrentThemes(removeWebClips: removeWebClips, progress: { str in
                UIApplication.shared.change(title: "In progress", body: str)
            })
            DispatchQueue.main.async {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                UIApplication.shared.change(title: "Rebuilding Icon Cache...", body: "Device will respring after rebuild")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    try! RootHelper.rebuildIconCache()
                })
            }
        }
    }
}


struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
