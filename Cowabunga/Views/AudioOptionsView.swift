//
//  AudioOptionsView.swift
//  Cowabunga
//
//  Created by lemin on 1/20/23.
//

import SwiftUI

enum SoundCategory: String {
    case device = "Device"
    case camera = "Camera"
    case messages = "Messages"
    case payment = "Payment"
}

struct AudioOptionsView: View {
    var Category: SoundCategory
    
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
        .init(category: SoundCategory.device, key: AudioFiles.SoundEffect.notification, title: "Default Notifications", imageName: "iphone.radiowaves.left.and.right"),
        
        // Camera Category
        .init(category: SoundCategory.camera, key: AudioFiles.SoundEffect.screenshot, title: "Screenshot", imageName: "photo"),
        
        // Messages Category
        .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.sentMessage, title: "Sent Message", imageName: "bubble.right.fill"),
        .init(category: SoundCategory.messages, key: AudioFiles.SoundEffect.receivedMessage, title: "Received Message", imageName: "bubble.left"),
        
        // Payment Category
        .init(category: SoundCategory.payment, key: AudioFiles.SoundEffect.paymentSuccess, title: "Payment Success", imageName: "creditcard"),
    ]
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach($audioOptions) { option in
                        if option.category.wrappedValue == Category {
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
                                    Text((UserDefaults.standard.string(forKey: option.key.wrappedValue.rawValue+"_Applied") ?? "Default").replacingOccurrences(of: "USR_", with: ""))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Category.rawValue + " Sounds")
            }
        }
    }
}

struct AudioOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        AudioOptionsView(Category: SoundCategory.device)
    }
}
