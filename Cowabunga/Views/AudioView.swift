//
//  AudioView.swift
//  Cowabunga
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioView: View {
    struct Category: Identifiable {
        var key: SoundCategory
        var id = UUID()
        var title: String
        var imageName: String
        var active: Bool = false
    }
    
    struct AudioOption: Identifiable {
        var category: SoundCategory
        var key: AudioFiles.SoundEffect
        var id = UUID()
        var title: String
        var imageName: String
        var active: Bool = false
    }
    
    @State var audioOptions: [AudioOption] = [
        // Device Category
        .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.charging, title: "Charging", imageName: "bolt.fill"),
        .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.lock, title: "Lock", imageName: "lock"),
        .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.lowPower, title: "Low Power", imageName: "battery.25"),
        .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.notification, title: "Default Notifications", imageName: "iphone.radiowaves.left.and.right"),
        
        // Camera Category
        .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.screenshot, title: "Screenshot", imageName: "photo"),
        .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.beginRecording, title: "Begin Recording", imageName: "record.circle"),
        .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.endRecording, title: "End Recording", imageName: "stop"),
        
        // Messages Category
        .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMessage, title: "Sent Message", imageName: "bubble.right.fill"),
        .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.receivedMessage, title: "Received Message", imageName: "bubble.left"),
        .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMail, title: "Sent Mail", imageName: "envelope"),
        .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.newMail, title: "New Mail", imageName: "envelope.badge"),
        
        // Payment Category
        .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentSuccess, title: "Payment Success", imageName: "creditcard"),
        .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentFailed, title: "Payment Failed", imageName: "creditcard.trianglebadge.exclamationmark"),
        .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentReceived, title: "Payment Received", imageName: "creditcard.viewfinder"),
    ]
    
    @State var audioCategories: [Category] = [
        .init(key: SoundCategory.device, title: "Device", imageName: "iphone"),
        .init(key: SoundCategory.camera, title: "Camera", imageName: "camera"),
        .init(key: SoundCategory.messages, title: "Messages", imageName: "message"),
        .init(key: SoundCategory.payment, title: "Payment", imageName: "creditcard")
    ]
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        ForEach($audioCategories) { option in
                            NavigationLink(destination: AudioOptionsView(Category: option.key.wrappedValue), isActive: option.active) {
                                HStack {
                                    Image(systemName: option.imageName.wrappedValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                    Text(option.title.wrappedValue)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                    } header: {
                        Text("Categories")
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
                                        print("failed to apply audio for " + audioOption.key.rawValue)
                                        failed = true
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
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
