//
//  ThemeView.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import SwiftUI


struct ThemeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State var theme: Theme
    var wallpaper: UIImage
    var defaultWallpaper: Bool = false
    @State var icons: [UIImage?] = []
    @State var selected: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: wallpaper)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 90)
                    .scaleEffect(defaultWallpaper ? 2 : 1)
                    .clipped()
                    .cornerRadius(8)
                    .allowsHitTesting(false)
                if icons.count >= 8 {
                    VStack {
                        HStack {
                            ForEach(icons[0...3], id: \.self) {
                                if $0 != nil {
                                    Image(uiImage: $0!)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(5)
                                        .padding(2)
                                }
                            }
                        }
                        HStack {
                            ForEach(icons[4...7], id: \.self) {
                                if $0 != nil {
                                    Image(uiImage: $0!)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(5)
                                        .padding(2)
                                }
                            }
                        }
                    }
                }
            }
            HStack {
                Text(theme.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text("· \(theme.iconCount)")
                    .font(.headline)
                    .foregroundColor(Color.secondary)
                Spacer()
            }
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if selected {
                    themeManager.preferedThemes.removeAll { t in t.name == theme.name }
                } else {
                    themeManager.preferedThemes.append(theme)
                }
                selected.toggle()
                remLog(themeManager.preferedIcons.keys.count, themeManager.preferedThemes.count)
            }) {
                Text(selected ? "Selected" : "Select")
                    .frame(maxWidth: .infinity)
                
            }
            .padding(10)
            .background(selected ? Color.blue : Color(uiColor14: UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .foregroundColor(selected ? .white : .init(uiColor14: .label) )
        }
        .padding(10)
        .background(Color(uiColor14: .secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            icons = (try? themeManager.icons(forAppIDs: ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"], from: theme)) ?? []
            selected = themeManager.preferedThemes.contains(where: { t in t.name == theme.name })
        }
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView(theme: Theme(name: "Theme", iconCount: 23), wallpaper: UIImage(named: "wallpaper")!)
            .frame(width: 190)
    }
}
