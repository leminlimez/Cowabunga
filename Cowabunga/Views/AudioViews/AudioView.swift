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
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.charging, title: NSLocalizedString("Charging", comment: "Audio name"), imageName: "bolt.fill"),
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.lock, title: NSLocalizedString("Lock", comment: "Audio name"), imageName: "lock"),
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.lowPower, title: NSLocalizedString("Low Power", comment: "Audio name"), imageName: "battery.25"),
            .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.notification, title: NSLocalizedString("Default Notifications", comment: "Audio name"), imageName: "iphone.radiowaves.left.and.right")
        ]),
        .init(title: "Camera", options: [
            .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.screenshot, title: NSLocalizedString("Screenshot", comment: "Audio name"), imageName: "photo"),
            .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.beginRecording, title: NSLocalizedString("Begin Recording", comment: "Audio name"), imageName: "record.circle"),
            .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.endRecording, title: NSLocalizedString("End Recording", comment: "Audio name"), imageName: "stop")
        ]),
        .init(title: "Messages", options: [
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMessage, title: NSLocalizedString("Sent Message", comment: "Audio name"), imageName: "bubble.right.fill"),
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.receivedMessage, title: NSLocalizedString("Received Message", comment: "Audio name"), imageName: "bubble.left"),
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMail, title: NSLocalizedString("Sent Mail", comment: "Audio name"), imageName: "envelope"),
            .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.newMail, title: NSLocalizedString("New Mail", comment: "Audio name"), imageName: "envelope.badge")
        ]),
        .init(title: "Payment", options: [
            .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentSuccess, title: NSLocalizedString("Payment Success", comment: "Audio name"), imageName: "creditcard"),
            .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentFailed, title: NSLocalizedString("Payment Failed", comment: "Audio name"), imageName: "creditcard.trianglebadge.exclamationmark"),
            .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentReceived, title: NSLocalizedString("Payment Received", comment: "Audio name"), imageName: "square.and.arrow.down.on.square")
        ]),
        .init(title: "Keyboard", options: [
            .init(category: SoundCategory.keyboard, key: AudioFiles.SoundEffect.kbKeyClick, title: NSLocalizedString("Keyboard Press Normal", comment: "Audio name"), imageName: "square"),
            .init(category: SoundCategory.keyboard, key: AudioFiles.SoundEffect.kbKeyDel, title: NSLocalizedString("Keyboard Press Delete", comment: "Audio name"), imageName: "delete.left"),
            .init(category: SoundCategory.keyboard, key: AudioFiles.SoundEffect.kbKeyMod, title: NSLocalizedString("Keyboard Press Clear", comment: "Audio name"), imageName: "keyboard.badge.ellipsis")
        ])
    ]
    
    var body: some View {
        VStack {
            //NavigationView {
                List {
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
                            Text(NSLocalizedString(cat.title.wrappedValue, comment: "Header of audio"))
                        }
                    }
                    
                    Button(action: {
                        // apply the audio
                        let succeeded = AudioFiles.applyAllAudio()
                        if !succeeded {
                            UIApplication.shared.alert(body: NSLocalizedString("Failed to apply audio for:", comment: "Failed to apply audio") + " " + AudioFiles.applyFailedMessage + ".")
                        } else {
                            UIApplication.shared.alert(title: NSLocalizedString("Successfully applied audio!", comment: "applying audio succeeded"), body: NSLocalizedString("Please respring to hear changes.", comment: "respring to hear audio changes"))
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
        //}
    }
}

struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        AudioView()
    }
}
