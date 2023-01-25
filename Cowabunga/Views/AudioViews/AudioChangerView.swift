//
//  AudioChangerView.swift
//  Cowabunga
//
//  Created by lemin on 1/9/23.
//

import SwiftUI
import AVFoundation
import MobileCoreServices

var player: AVAudioPlayer?

struct AudioChangerView: View {
    var SoundIdentifier: AudioFiles.SoundEffect
    
    // included audio files
    struct IncludedAudioName: Identifiable {
        var id = UUID()
        var attachments: [AudioFiles.SoundEffect]
        var audioName: String
        var checked: Bool
    }
    
    // custom audio files
    struct CustomAudioName: Identifiable {
        var id = UUID()
        var audioName: String
        var displayName: String
        var checked: Bool
    }
    
    // list of included audio files
    @State var audioFiles: [IncludedAudioName] = [
    ]
    
    // list of custom audio files
    @State var customAudio: [CustomAudioName] = [
    ]
    
    // applied sound
    @State private var appliedSound: String = "Default"
    
    @State private var isImporting: Bool = false
    
    @State private var generated: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach($audioFiles) { audio in
                        if (audio.attachments.wrappedValue).contains(SoundIdentifier) {
                            // create button
                            HStack {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.blue)
                                    .opacity(audio.checked.wrappedValue ? 1: 0)
                                
                                Button(audio.audioName.wrappedValue.replacingOccurrences(of: "_", with: " "), action: {
                                    if appliedSound != audio.audioName.wrappedValue {
                                        for (i, file) in audioFiles.enumerated() {
                                            if file.audioName == appliedSound {
                                                audioFiles[i].checked = false
                                            } else if file.audioName == audio.audioName.wrappedValue {
                                                audioFiles[i].checked = true
                                            }
                                        }
                                        
                                        for (i, file) in customAudio.enumerated() {
                                            if file.audioName == appliedSound {
                                                customAudio[i].checked = false
                                            } else if file.audioName == audio.audioName.wrappedValue {
                                                customAudio[i].checked = true
                                            }
                                        }
                                        appliedSound = audio.audioName.wrappedValue
                                        // save to defaults
                                        UserDefaults.standard.set(appliedSound, forKey: SoundIdentifier.rawValue+"_Applied")
                                    }
                                    // preview the sound
                                    if audio.audioName.wrappedValue != "Default" && audio.audioName.wrappedValue != "Off" {
                                        previewAudio(audioName: audio.audioName.wrappedValue)
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
                
                Section {
                    ForEach($customAudio) { audio in
                        // create button
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .foregroundColor(.blue)
                                .opacity(audio.checked.wrappedValue ? 1: 0)
                            
                            Button(audio.displayName.wrappedValue, action: {
                                if appliedSound != audio.audioName.wrappedValue {
                                    for (i, file) in audioFiles.enumerated() {
                                        if file.audioName == appliedSound {
                                            audioFiles[i].checked = false
                                        } else if file.audioName == audio.audioName.wrappedValue {
                                            audioFiles[i].checked = true
                                        }
                                    }
                                    
                                    for (i, file) in customAudio.enumerated() {
                                        if file.audioName == appliedSound {
                                            customAudio[i].checked = false
                                        } else if file.audioName == audio.audioName.wrappedValue {
                                            customAudio[i].checked = true
                                        }
                                    }
                                    appliedSound = audio.audioName.wrappedValue
                                    // save to defaults
                                    UserDefaults.standard.set(appliedSound, forKey: SoundIdentifier.rawValue+"_Applied")
                                }
                                // preview the sound
                                previewAudio(audioName: audio.audioName.wrappedValue)
                            })
                            .padding(.horizontal, 8)
                            .foregroundColor(.primary)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            let deletingAudioName = customAudio[i].audioName
                            print("Deleting: " + deletingAudioName)
                            if customAudio[i].checked {
                                // check default instead
                                for (i, file) in audioFiles.enumerated() {
                                    if file.audioName == "Default" {
                                        audioFiles[i].checked = true
                                        appliedSound = "Default"
                                        UserDefaults.standard.set("Default", forKey: SoundIdentifier.rawValue+"_Applied")
                                        for (_, id) in file.attachments.enumerated() {
                                            // uncheck if applied elsewhere
                                            if UserDefaults.standard.string(forKey: id.rawValue+"_Applied") == deletingAudioName {
                                                UserDefaults.standard.set("Default", forKey: id.rawValue+"_Applied")
                                            }
                                        }
                                        break
                                    }
                                }
                            }
                            // delete the file
                            do {
                                let url = AudioFiles.getAudioDirectory()!.appendingPathComponent(deletingAudioName+".m4a")
                                try FileManager.default.removeItem(at: url)
                                customAudio.remove(at: i)
                            } catch {
                                UIApplication.shared.alert(body: "Unable to delete audio for audio \"" + customAudio[i].displayName + "\"!")
                            }
                        }
                    }
                } header: {
                    Text("Custom")
                }
            }
        }
        .navigationTitle(SoundIdentifier.rawValue)
        .toolbar {
            Button(action: {
                // import a custom audio
                // allow the user to choose the file
                isImporting.toggle()
            }, label: {
                Image(systemName: "square.and.arrow.down")
            })
        }
        .onAppear {
            if !generated {
                appliedSound = UserDefaults.standard.string(forKey: SoundIdentifier.rawValue+"_Applied") ?? "Default"
                // add off
                let audios: [AudioFiles.SoundEffect] = AudioFiles.SoundEffect.allCases
                audioFiles.append(IncludedAudioName.init(attachments: audios, audioName: "Off", checked: (appliedSound == "Off")))
                // add default
                audioFiles.append(IncludedAudioName.init(attachments: audios, audioName: "Default", checked: (appliedSound == "Default")))
                
                // get the included audio
                if AudioFiles.ListOfAudio[SoundIdentifier.rawValue] != nil {
                    for audioName in AudioFiles.ListOfAudio[SoundIdentifier.rawValue]! {
                        if audioName != "Default" {
                            var checked: Bool = false
                            if audioName == appliedSound {
                                checked = true
                            }
                            audioFiles.append(IncludedAudioName.init(attachments: [SoundIdentifier], audioName: audioName, checked: checked))
                        }
                    }
                }
                
                // get the custom audio
                let customAudioTitles = AudioFiles.getCustomAudio()
                for audio in customAudioTitles {
                    var checked: Bool = false
                    if audio == appliedSound {
                        checked = true
                    }
                    customAudio.append(CustomAudioName.init(audioName: audio, displayName: audio.replacingOccurrences(of: "USR_", with: ""), checked: checked))
                }
                
                generated = true
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            // user chose a file
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of file. Did you select it?"); return }
            guard url.startAccessingSecurityScopedResource() else { UIApplication.shared.alert(body: "File permission error"); return }
            
            // ask for a name for the sound
            let alert = UIAlertController(title: "Enter Name", message: "Choose a name for the sound", preferredStyle: .alert)
            
            // bring up the text prompts
            alert.addTextField { (textField) in
                // text field for width
                textField.placeholder = "Name"
                textField.text = url.deletingPathExtension().lastPathComponent
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
                    customaudio(fileURL: url) { audioData in
                        if audioData != nil {
                            // success
                            UIApplication.shared.alert(title: "Successfully saved audio", body: "The imported audio was successfully encoded and saved.")
                            // add to the list
                            customAudio.append(CustomAudioName.init(audioName: "USR_" + fileName, displayName: fileName, checked: false))
                            url.stopAccessingSecurityScopedResource()
                        } else {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // cancel the process
                url.stopAccessingSecurityScopedResource()
            })
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func previewAudio(audioName: String) {
        // get the directory of the file
        var newURL: URL?
        if audioName.starts(with: "USR_") {
            newURL = AudioFiles.getAudioDirectory()!.appendingPathComponent(audioName + ".m4a")
        } else if audioName != "Default" && audioName != "Off" {
            newURL = AudioFiles.getIncludedAudioDirectory()!.appendingPathComponent(audioName + ".m4a")
        }
        
        // play the audio
        do {
            if newURL != nil {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = try AVAudioPlayer(contentsOf: newURL!, fileTypeHint: AVFileType.m4a.rawValue)
                guard let player = player else { return }
                
                player.play()
            } else {
                print("Could not get audio file URL")
            }
        } catch {
            print("Error playing audio file")
            print(error.localizedDescription)
        }
    }
}

struct AudioChangerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioChangerView(SoundIdentifier: AudioFiles.SoundEffect.charging)
    }
}
