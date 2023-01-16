//
//  AudioChangerView.swift
//  DockHider
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioChangerView: View {
    var SoundIdentifier: AudioFiles.SoundEffect
    
    // included audio files
    struct IncludedAudioName: Identifiable {
        var id = UUID()
        var attachment: AudioFiles.SoundEffect
        var audioName: String
        var checked: Bool = false
    }
    
    // list of included audio files
    @State var audioFiles: [IncludedAudioName] = [
        // charging
        .init(attachment: AudioFiles.SoundEffect.charging, audioName: "Default"),
        .init(attachment: AudioFiles.SoundEffect.charging, audioName: "Old"),
        .init(attachment: AudioFiles.SoundEffect.charging, audioName: "Engage"),
        .init(attachment: AudioFiles.SoundEffect.charging, audioName: "MagSafe"),
        
        // lock
        .init(attachment: AudioFiles.SoundEffect.lock, audioName: "Default"),
        .init(attachment: AudioFiles.SoundEffect.lock, audioName: "Old"),
        
        // notification
        .init(attachment: AudioFiles.SoundEffect.notification, audioName: "Default"),
        .init(attachment: AudioFiles.SoundEffect.notification, audioName: "Samsung"),
        .init(attachment: AudioFiles.SoundEffect.notification, audioName: "Taco Bell"),
        
        // screenshot
        .init(attachment: AudioFiles.SoundEffect.screenshot, audioName: "Default"),
        
        // sent message
        .init(attachment: AudioFiles.SoundEffect.sentMessage, audioName: "Default"),
        
        // received message
        .init(attachment: AudioFiles.SoundEffect.receivedMessage, audioName: "Default"),
        
        // payment success
        .init(attachment: AudioFiles.SoundEffect.paymentSuccess, audioName: "Default"),
    ]
    
    // applied sound
    @State private var appliedSound: String = "Default"
    
    @State private var isImporting: Bool = true
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach($audioFiles) { audio in
                        if audio.attachment.wrappedValue == SoundIdentifier {
                            // create button
                            HStack {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.blue)
                                    .opacity(audio.checked.wrappedValue ? 1: 0)
                                
                                Button(audio.audioName.wrappedValue, action: {
                                    if appliedSound != audio.audioName.wrappedValue {
                                        for (i, file) in audioFiles.enumerated() {
                                            if file.audioName == appliedSound {
                                                audioFiles[i].checked = false
                                            } else if file.audioName == audio.audioName.wrappedValue {
                                                audioFiles[i].checked = true
                                            }
                                        }
                                        appliedSound = audio.audioName.wrappedValue
                                        // save to defaults
                                        UserDefaults.standard.set(appliedSound, forKey: SoundIdentifier.rawValue+"_Applied")
                                    }
                                })
                                .padding(.horizontal, 8)
                                .foregroundColor(.primary)
                            }
                        }
                    }
                } header: {
                    Text("Included")
                }
            }
        }
        .navigationTitle(SoundIdentifier.rawValue)
        .toolbar {
            Button(action: {
                // import a custom audio
                // allow the user to choose the file
                isImporting = true
            }) {
                Image(systemName: "square.and.arrow.down")
            }
        }
        .onAppear {
            appliedSound = UserDefaults.standard.string(forKey: SoundIdentifier.rawValue+"_Applied") ?? "Default"
            for (i, file) in audioFiles.enumerated() {
                if file.audioName == appliedSound {
                    audioFiles[i].checked = true
                }
            }
        }
        .fileImporter(isPresented: $isImporting,
                      allowedContentTypes: [
                        .mp3, .wav
                      ],
                      allowsMultipleSelection: false
        ) { result in
            // user chose a file
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of file. Did you select it?"); return }
            
            // ask for a name for the sound
            let alert = UIAlertController(title: "Enter Name", message: "Choose a name for the sound", preferredStyle: .alert)
            
            // bring up the text prompts
            alert.addTextField { (textField) in
                // text field for width
                textField.placeholder = "Name"
            }
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
                // set the name and add the file
                if alert.textFields?[0].text != nil {
                    // check if it is a valid name
                    let validChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890._")
                    var fileName: String = (alert.textFields?[0].text ?? "Unnamed").filter{validChars.contains($0)}
                    if fileName == "" {
                        // set to unnamed
                        fileName = "Unnamed"
                    }
                    // get the base64 data
                    let base64 = customaudio(filepath: url.path)
                    if base64 != nil {
                        // write the file
                        let dataToWrite: [String: String] = [
                            "Name": "USR_" + fileName,
                            "AudioData": base64!
                        ]
                        
                        do {
                            let plistData = try PropertyListSerialization.data(fromPropertyList: dataToWrite, format: .xml, options: 0)
                            let newURL: URL = URL.documents.appendingPathComponent("Cowabunga_Audio/USR_"+fileName+".plist")
                            try plistData.write(to: newURL)
                            UIApplication.shared.alert(title: "Successfully saved audio", body: "The imported audio was successfully encoded and saved.")
                        } catch {
                            print(error.localizedDescription)
                            UIApplication.shared.alert(body: "An unexpected error occurred when attempting to save the file.")
                        }
                    }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // cancel the process
            })
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

struct AudioChangerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioChangerView(SoundIdentifier: AudioFiles.SoundEffect.charging)
    }
}
