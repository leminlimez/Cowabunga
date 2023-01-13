//
//  AudioView.swift
//  DockHider
//
//  Created by lemin on 1/9/23.
//

import SwiftUI

struct AudioView: View {
    struct AudioOption: Identifiable {
        var key: AudioFiles.SoundEffect
        var value: String // currently equipped audio
        var id = UUID()
        var title: String
        var imageName: String
        var active: Bool = false
    }
    
    @State var audioOptions: [AudioOption] = [
        .init(key: AudioFiles.SoundEffect.charging, value: "Default", title: "Charging Sound", imageName: "powerplug"),
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
                                    Text(UserDefaults.standard.string(forKey: option.key.wrappedValue.rawValue+"_Applied") ?? "Default")
                                        .padding(.leading, 45)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } header: {
                        Text("Sound Effects Modifications")
                    }
                    Button("Apply", action: {
                        print("h")
                    })
                    .padding(10)
                }
            }
        }
    }
}

struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        AudioView()
    }
}
