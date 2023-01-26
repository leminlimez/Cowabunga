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
    
    @State var audioCategories: [Category] = [
        .init(key: SoundCategory.device, title: "Device", imageName: "iphone"),
        .init(key: SoundCategory.camera, title: "Camera", imageName: "camera"),
        .init(key: SoundCategory.messages, title: "Messages", imageName: "message"),
        .init(key: SoundCategory.payment, title: "Payment", imageName: "creditcard"),
        .init(key: SoundCategory.keyboard, title: "Keyboard", imageName: "keyboard")
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
                        let succeeded = AudioFiles.applyAllAudio()
                        if !succeeded {
                            UIApplication.shared.alert(body: "Failed to apply audio for: " + AudioFiles.applyFailedMessage + ".")
                        } else {
                            UIApplication.shared.alert(title: "Successfully applied audio!", body: "Please respring to hear changes.")
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
