//  SetupView.swift
//  DirtyJIT
//
//  Created by Yuri Anokhin on 03.03.2023.
// ty ChatGPT

import SwiftUI

@available(iOS 15.0, *)
struct SetupView: View {
    @Environment(\.dismiss) var dismiss
    let jit = JIT.shared
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Welcome!")) {
                    Text("DirtyJIT is a JIT enabler app that uses the MacDirtyCow (CVE-2022-46689) privilege escalation vulnerability in macOS, which also works on iOS. It can be used with apps, emulators, or any software that requires JIT to work (Such as PojavLauncher, DolphiniOS). You need to perform some setup steps to make this app work on your device. Let's get started!")
                }
                
                Section(header: Text("Step 1")) {
                    Text("Download the attachments that matches your device's iOS version from the latest action and then drop them in a folder, you can find the link below. (We'll need this for later!)")
                    Button("Visit") {
                        UIApplication.shared.open(URL(string: "https://github.com/verygenericname/WDBDDISSH/actions")!)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
                
                Section(header: Text("Step 2")) {
                    Text("Download the file from the link below. It should appear in Settings. Install it, disconnect your phone from your PC if you haven't yet and then reboot your device.")
                    Button("Install Profile") {
                        UIApplication.shared.open(URL(string: "https://cdn.discordapp.com/attachments/985930068188602394/1081214719534301255/cert.pem")!)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
                
                Section(header: Text("Step 3")) {
                    Text("After rebooting, press the button below to replace iPhoneDebug.pem with cert.pem. Make sure you are NOT connected to a PC!")
                    Button("Replace File") {
                        jit.replaceDebug()
                    }
                    .buttonStyle(DangerButtonStyle())
                }
                
                Section(header: Text("Step 4")) {
                    Text("After replacing the file, you can finally connect your device to your PC. Run the commands on your PC from below to finally mount the image from the first step. Make sure you have ideviceimagemounter installed and you cd'ed in the folder where you downloaded those files. If the commands won't work, disconnect and reboot your phone, replacing the certificate again and then try again (Step 3).")
                    VStack {
                        Text("ideviceimagemounter DeveloperDiskImageModified_YourVersionHere.dmg DeveloperDiskImageModified_YourVersionHere.dmg.signature")
                            .font(.custom("Menlo", size: 15))
                            .padding()
                    }
                    .textSelection(.enabled)
                    .background (
                        Color.black
                            .cornerRadius(5)
                    )
                }
                
                Section(header: Text("Step 5")) {
                    Text("Congratulations! If you haven't encountered any errors, you have finished the setup and now you are good to go. Please note that after rebooting, you still need to repeat steps 3 and 4; Otherwise, you are good to go and you can finally click the dismiss button. If you still have questions or you encountered some errors, ask for help in the Cowabunga or haxi0 Discord server.")
                    Button("Visit the Discord Server") {
                        UIApplication.shared.open(URL(string: "https://discord.gg/Cowabunga")!)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
            }
            .navigationTitle("Setup")
            .environment(\.defaultMinListRowHeight, 50)
        }
        .interactiveDismissDisabled()
        
        Button("Dismiss") {
            close()
        }
        .buttonStyle(DangerButtonStyle())
        .padding()
    }
    
    func close() {
        dismiss()
    }
}
