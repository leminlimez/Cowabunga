//
//  AudioView.swift
//  Cowabunga
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioView: View {
    struct Category: Identifiable {
        var id = UUID()
        var title: String
        var options: [AudioOption]
    }
    
    struct AudioOption: Identifiable {
        var category: SoundCategory
        var key: AudioFiles.SoundEffect
        var id = UUID()
        var title: String
        var imageName: String
        var active: Bool = false
    }
    
    @State var audioCategories: [Category] = [
        .init(title: "Device", options: [
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.charging, title: "Charging", imageName: "bolt.fill"),
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.lock, title: "Lock", imageName: "lock"),
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.lowPower, title: "Low Power", imageName: "battery.25"),
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.notification, title: "Default Notifications", imageName: "iphone.radiowaves.left.and.right")
        ]),
        .init(title: "Camera", options: [
            .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.screenshot, title: "Screenshot", imageName: "photo"),
            .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.beginRecording, title: "Begin Recording", imageName: "record.circle"),
            .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.endRecording, title: "End Recording", imageName: "stop")
        ]),
        .init(title: "Messages", options: [
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMessage, title: "Sent Message", imageName: "bubble.right.fill"),
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.receivedMessage, title: "Received Message", imageName: "bubble.left"),
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMail, title: "Sent Mail", imageName: "envelope"),
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.newMail, title: "New Mail", imageName: "envelope.badge")
        ]),
        .init(title: "Payment", options: [
            .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentSuccess, title: "Payment Success", imageName: "creditcard"),
            .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentFailed, title: "Payment Failed", imageName: "creditcard.trianglebadge.exclamationmark"),
            .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentReceived, title: "Payment Received", imageName: "square.and.arrow.down.on.square")
        ]),
        .init(title: "Keyboard", options: [
            .init(category: SoundCategory.keyboard, key: AudioFiles.SoundEffect.kbKeyClick, title: "Keyboard Press Normal", imageName: "square"),
            .init(category: SoundCategory.keyboard, key: AudioFiles.SoundEffect.kbKeyDel, title: "Keyboard Press Delete", imageName: "delete.left"),
            .init(category: SoundCategory.keyboard, key: AudioFiles.SoundEffect.kbKeyMod, title: "Keyboard Press Clear", imageName: "keyboard.badge.ellipsis")
        ])
    ]
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        ForEach($audioCategories) { cat in
                            Section {
                                ForEach(cat.options) { option in
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
                                            Text((UserDefaults.standard.string(forKey: option.key.wrappedValue.rawValue+"_Applied") ?? "Default").replacingOccurrences(of: "USR_", with: "").replacingOccurrences(of: "_", with: " "))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            } header: {
                                Text(cat.title.wrappedValue)
                            }
                        }
                    } header: {
                        Text("Categories")
                    }
                    
                    Button(action: {
                        // apply the audio
                        let succeeded = AudioFiles.applyAllAudio()
                        if !succeeded {
                            UIApplication.shared.alert(body: "Failed to apply audio for: " + AudioFiles.applyFailedMessage + ".")
                        } else {
                            UIApplication.shared.alert(title: "Successfully applied audio!", body: "Please respring to hear changes.")
                        }
                    }) {
                        Text("Apply")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .cornerRadius(8)
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
