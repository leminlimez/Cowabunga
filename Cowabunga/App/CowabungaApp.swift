//
//  CowabungaApp.swift
//  Cowabunga
//
//  Created by lemin on 1/3/23.
//

import SwiftUI
import Darwin

@main
struct CowabungaApp: App {
    //let locationManager = LocationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var cowabungaAPI = CowabungaAPI()
    
    @State var catalogFixupShown = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(cowabungaAPI)
                .onAppear {
                    performCatalogFixupIfNeeded()
                    
                    // clear image cache
                    //URLCache.imageCache.removeAllCachedResponses()
                    
#if targetEnvironment(simulator)
#else
                    if #available(iOS 16.2, *) {
                        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.")
                    } else {
                        do {
                            // TrollStore method
                            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
                            StatusManager.sharedInstance().setIsMDCMode(false)
                        } catch {
                            // MDC method
                            // grant r/w access
                            if #available(iOS 15, *) {
                                grant_full_disk_access() { error in
                                    if (error != nil) {
                                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.")
                                    } else {
                                        StatusManager.sharedInstance().setIsMDCMode(true)
                                    }
                                }
                            } else {
                                UIApplication.shared.alert(title: "MDC Not Supported", body: "Please install via TrollStore")
                            }
                        }
                    }
#endif
                    // credit: TrollTools
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/leminlimez/Cowabunga/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    UIApplication.shared.confirmAlert(title: "Update available", body: "A new Cowabunga update is available, do you want to visit releases page?", onOK: {
                                        UIApplication.shared.open(URL(string: "https://github.com/leminlimez/Cowabunga/releases/latest")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }
                    AudioFiles.setup(fetchingNewAudio: UserDefaults.standard.bool(forKey: "AutoFetchAudio"))
                    //LockManager.setup(fetchingNewLocks: UserDefaults.standard.bool(forKey: "AutoFetchLocks"))
                    if UserDefaults.standard.bool(forKey: "BackgroundApply") == true {
                        ApplicationMonitor.shared.start()
                    }
                }
                .onOpenURL(perform: { url in
                    // for opening passthm files
                    if url.pathExtension.lowercased() == "passthm" {
                        let defaultKeySize = PasscodeKeyFaceManager.getDefaultFaceSize()
                        do {
                            // try appying the themes
                            try PasscodeKeyFaceManager.setFacesFromTheme(url, keySize: CGFloat(defaultKeySize), customX: CGFloat(150), customY: CGFloat(150))
                            // show the passcode screen
                            //PasscodeEditorView()
                            UIApplication.shared.alert(title: "Success!", body: "Successfully imported and applied passcode theme!")
                        } catch { UIApplication.shared.alert(body: error.localizedDescription) }
                    }
                    
                    // for opening zips of app themes
                    if url.pathExtension.lowercased() == "zip" {
                        let themeName = url.deletingPathExtension().lastPathComponent
                        let saveURL = rawThemesDir.appendingPathComponent(themeName)
                        
                        do {
                            let tmpExtract = saveURL.deletingLastPathComponent().appendingPathComponent("tmp_extract")
                            if FileManager.default.fileExists(atPath: tmpExtract.path) {
                                try? FileManager.default.removeItem(at: tmpExtract)
                            }
                            try FileManager.default.unzipItem(at: url, to: tmpExtract)
                            
                            let theme = try ThemeManager.shared.importTheme(from: tmpExtract.appendingPathComponent(themeName))
                            ThemeManager.shared.themes.append(theme)
                            
                            try FileManager.default.removeItem(at: tmpExtract)
                            UIApplication.shared.alert(title: NSLocalizedString("Success", comment: ""), body: NSLocalizedString("App theme was successfully saved!", comment: ""))
                        } catch {
                            UIApplication.shared.alert(title: NSLocalizedString("Failed to save theme!", comment: ""), body: error.localizedDescription)
                        }
                    }
                })
                .sheet(isPresented: $catalogFixupShown) {
                    if #available(iOS 15.0, *) {
                        CatalogFixupView()
                    }
                }
        }
    }
    
    func performCatalogFixupIfNeeded() {
        if UserDefaults.standard.bool(forKey: "shouldPerformCatalogFixup") {
            catalogFixupShown = true
        }
    }
}

