//
//  SettingsView.swift
//  StatusMagic
//
//  Created by Rory Madden on 7/2/2023.
//

import SwiftUI

struct SettingsView: View {
    @State private var forceMDC = UserDefaults.standard.bool(forKey: "ForceMDC")
    @State private var useAlternativeSetter = UserDefaults.standard.bool(forKey: "UseAlternativeSetter")
    
    func saveSettings() {
        UserDefaults.standard.set(forceMDC, forKey: "ForceMDC")
        UserDefaults.standard.set(useAlternativeSetter, forKey: "UseAlternativeSetter")
        exitGracefully()
    }
    
    func exitGracefully() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            exit(0)
        }
    }
    
    var body: some View {
        Form {
            List {
                Section(footer: Text("The app will quit.")) {
                    Button("Save Settings") {
                        saveSettings()
                    }
                }
                if #available(iOS 15.0, *) {
                    Section(footer: Text("Use this if your device is erroneously detecting TrollStore installed, and you do not have an Apply button at the top of StatusMagic.")) {
                        Toggle(isOn: $forceMDC) {
                            Text("Force MacDirtyCOW")
                        }
                    }
                }
                if #available(iOS 16.1, *) {
                    Section(footer: Text("Use this if carrier/time text isn't applying. I would recommend you Reset to Defaults after turning on and saving.")) {
                        Toggle(isOn: $useAlternativeSetter) {
                            Text("Use Alternative Setter")
                        }
                    }
                }
            }
        }.navigationBarTitle("Settings", displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
