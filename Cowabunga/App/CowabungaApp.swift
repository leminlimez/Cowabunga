//
//  CowabungaApp.swift
//  Cowabunga
//
//  Created by lemin on 1/3/23.
//

import SwiftUI
import Darwin
import MacDirtyCowSwift

@main
struct CowabungaApp: App {
    //let locationManager = LocationManager()
    @AppStorage("firstTime") private var firstTime = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var cowabungaAPI = CowabungaAPI()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let memoryWarningPublisher = NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
    
    @State var catalogFixupShown = false
    @State var importingFontShown = false
    @State var importingFontURL: URL? = nil
    
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
                            if UserDefaults.standard.bool(forKey: "ForceMDC") == true {
                                throw "Force MDC"
                            }
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
                    if !catalogFixupShown, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/leminlimez/Cowabunga/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    UIApplication.shared.confirmAlert(title: "Update available", body: "Cowabunga \(json["tag_name"] as? String ?? "update") is available, do you want to visit releases page?", onOK: {
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
                    let fm = FileManager.default
                    // MARK: URL Schemes
                    // for setting the date
                    if url.absoluteString == "cowabunga://dateset" {
                        createStatusBarDateTag()
                        return
                    }
                    // MARK: Status Bar
                    if url.absoluteString.starts(with: "cowabunga://statusbar") {
                        // reset status bar
                        if url.absoluteString == "cowabunga://statusbar:reset" {
                            if fm.fileExists(atPath: "/var/mobile/Library/SpringBoard/statusBarOverrides") {
                                do {
                                    try fm.removeItem(at: URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/statusBarOverrides"))
                                    restartFrontboard()
                                } catch {
                                    UIApplication.shared.alert(body: "\(error)")
                                }
                            }
                            return
                        }
                        return
                    }
                    
                    // for opening passthm files
                    if url.pathExtension.lowercased() == "passthm" {
                        let defaultKeySize = PasscodeKeyFaceManager.getDefaultFaceSize()
                        do {
                            // try appying the themes
                            try PasscodeKeyFaceManager.setFacesFromTheme(url, TelephonyDirType.passcode, colorScheme: colorScheme, keySize: CGFloat(defaultKeySize), customX: CGFloat(150), customY: CGFloat(150))
                            // show the passcode screen
                            //PasscodeEditorView()
                            UIApplication.shared.alert(title: "Success!", body: "Successfully imported and applied passcode theme!")
                        } catch { UIApplication.shared.alert(body: error.localizedDescription) }
                    }
                    
                    // for opening cowperation files
                    if url.pathExtension.lowercased() == "cowperation" || url.pathExtension.lowercased() == "fsp" {
                        do {
                            // try adding the operation
                            let editsVar = try AdvancedManager.importOperation(url)
                            if editsVar {
                                UIApplication.shared.alert(title: NSLocalizedString("⚠️ Warning ⚠️", comment: "warning for if a custom operation edits /var"), body: NSLocalizedString("The imported operation edits a file in the user folder (/var). This has the potential to permanently brick your device or cause bootloops. Only activate it if you know what you are doing and trust the source!", comment: "warning for if a custom operation edits /var"))
                            } else {
                                UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully imported.", comment: "when importing a custom operation"))
                            }
                        } catch { UIApplication.shared.alert(body: error.localizedDescription) }
                    }
                    
                    // for opening .theme app theme files
                    if url.pathExtension.lowercased() == "theme" {
                        do {
                            try ThemeManager.shared.importTheme(from: url)
                            
                            UIApplication.shared.alert(title: NSLocalizedString("Success", comment: ""), body: NSLocalizedString("App theme was successfully saved!", comment: ""))
                        } catch {
                            UIApplication.shared.alert(title: NSLocalizedString("Failed to save theme!", comment: ""), body: error.localizedDescription)
                        }
                    }
                    
                    // for opening font .ttf or .ttc files
                    if url.pathExtension.lowercased() == "ttf" || url.pathExtension.lowercased() == "ttc" || url.pathExtension.lowercased() == "otf" {
                        if !UserDefaults.standard.bool(forKey: "shouldPerformCatalogFixup") && !catalogFixupShown {
                            importingFontURL = url
                            importingFontShown = true
                        }
                    }
                })
                .sheet(isPresented: $firstTime) {
                    if #available(iOS 15, *) {
                        SetupView()
                    }
                }
                .sheet(isPresented: $importingFontShown) {
                    ImportingFontsView(isVisible: $importingFontShown, openingURL: $importingFontURL)
                }
                .sheet(isPresented: $catalogFixupShown) {
                    if #available(iOS 15.0, *) {
                        CatalogFixupView()
                    }
                }
        }
    }
    
    func performCatalogFixupIfNeeded() {
        if UserDefaults.standard.bool(forKey: "shouldPerformCatalogFixup") && !UserDefaults.standard.bool(forKey: "noThemingFixup") {
            catalogFixupShown = true
        }
    }
}

