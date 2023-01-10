//
//  AudioChangerView.swift
//  DockHider
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioChangerView: View {
    var SoundIdentifier: String
    
    // included audio files
    struct IncludedAudioName: Identifiable {
        var id = UUID()
        var attachment: String
        var audioName: String
        var fileName: String
        var checked: Bool = false
    }
    
    // list of included audio files
    @State var audioFiles: [IncludedAudioName] = [
        .init(attachment: "Charging", audioName: "Default", fileName: "Default_Charging"),
        .init(attachment: "Charging", audioName: "AirPower", fileName: "AirPower_Charging"),
    ]
    
    // applied sound
    @State private var appliedSound: String = "Default"
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        ForEach($audioFiles) { audio in
                            if audio.attachment.wrappedValue == SoundIdentifier {
                                // create button
                                // idk what I am doing with this but okay
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
                                            UserDefaults.standard.set(appliedSound, forKey: SoundIdentifier+"_Applied")
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
        }
        .onAppear {
            appliedSound = UserDefaults.standard.string(forKey: SoundIdentifier+"_Applied") ?? "Default"
            for (i, file) in audioFiles.enumerated() {
                if file.audioName == appliedSound {
                    audioFiles[i].checked = true
                }
            }
        }
    }
}

struct AudioChangerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioChangerView(SoundIdentifier: "Charging")
    }
}
