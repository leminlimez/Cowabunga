//
//  AudioView.swift
//  Cowabunga
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioView: View {
    struct AudioOption: Identifiable {
        var key: AudioFiles.SoundEffect
        var id = UUID()
        var title: String
        var imageName: String
        var active: Bool = false
    }
    
    @State var audioOptions: [AudioOption] = [
        .init(key: AudioFiles.SoundEffect.charging, title: "Charging", imageName: "bolt.fill"),
        .init(key: AudioFiles.SoundEffect.lock, title: "Lock", imageName: "lock"),
        .init(key: AudioFiles.SoundEffect.notification, title: "Default Notifications", imageName: "iphone.radiowaves.left.and.right"),
        .init(key: AudioFiles.SoundEffect.screenshot, title: "Screenshot", imageName: "photo"),
        //.init(key: AudioFiles.SoundEffect.sentMessage, title: "Sent Message", imageName: "bubble.right.fill"),
        //.init(key: AudioFiles.SoundEffect.receivedMessage, title: "Received Message", imageName: "bubble.left"),
        .init(key: AudioFiles.SoundEffect.paymentSuccess, title: "Payment Success", imageName: "creditcard"),
    ]
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        ForEach($audioOptions) { option in
                            NavigationLink(destination: AudioChangerView(SoundIdentifier: option.key.wrappedValue), isActive: option.active) {
                                HStack {
                                    Image(systemName: option.imageName.wrappedValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                    Text(option.title.wrappedValue)
                                        .padding(.horizontal, 8)
                                    Spacer()
                                    Text(UserDefaults.standard.string(forKey: option.key.wrappedValue.rawValue+"_Applied") ?? "Default")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } header: {
                        Text("Sound Effects Modifications")
                    }
                    Button(action: {
                        // apply the audio
                        var failed: Bool = false
                        for audioOption in audioOptions {
                            // apply if not default
                            let currentAudio: String = UserDefaults.standard.string(forKey: audioOption.key.rawValue+"_Applied") ?? "Default"
                            if currentAudio != "Default" {
                                overwriteFile(typeOfFile: OverwritingFileTypes.audio, fileIdentifier: audioOption.key.rawValue, currentAudio) { succeeded in
                                    if succeeded {
                                        print("successfully applied audio for " + audioOption.key.rawValue)
                                    } else {
                                        failed = true
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            if failed {
                                UIApplication.shared.alert(body: "Failed to apply some custom audio!")
                            } else {
                                UIApplication.shared.alert(title: "Successfully applied audio!", body: "Please respring to hear changes.")
                            }
                        }
                    }) {
                        if #available(iOS 15.0, *) {
                            Text("Apply")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .buttonStyle(.bordered)
                                .tint(.blue)
                                .cornerRadius(8)
                        } else {
                            // Fallback on earlier versions
                            Text("Apply")
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .cornerRadius(8)
                        }
                    }
                }
                .navigationTitle("Audio Changer")
            }
        }
    }
}

struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        AudioView()
    }
}
