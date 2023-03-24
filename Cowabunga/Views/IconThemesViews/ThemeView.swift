//
//  ThemeView.swift
//  TrollTools
//
//  Created by exerhythm on 22.10.2022.
//

import SwiftUI


struct ThemeView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @State var theme: Theme
    var wallpaper: UIImage?
    var defaultWallpaper: Bool = false
    @State var icons: [UIImage?] = []
    
    var body: some View {
        VStack {
            ZStack {
                if let wallpaper = wallpaper {
                    Image(uiImage: wallpaper)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 90)
                        .scaleEffect(defaultWallpaper ? 2 : 1)
                        .clipped()
                        .cornerRadius(8)
                        .allowsHitTesting(false)
                }
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
                    if icons.compactMap { $0 }.isEmpty {
                        noIconsFoundPreview
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
                if themeManager.preferedThemes.contains(theme) {
                    themeManager.preferedThemes.removeAll { t in t.name == theme.name }
                } else {
                    themeManager.preferedThemes.append(theme)
                }
            }) {
                let i = themeManager.preferedThemes.firstIndex(of: theme)
                Text(i == nil ? "Select" : "Selected: \(i! + 1)")
                    .frame(maxWidth: .infinity)
                
            }
            .padding(10)
            .background(themeManager.preferedThemes.contains(theme) ? Color.blue : Color(uiColor14: UIColor.tertiarySystemBackground))
            .cornerRadius(8)
            .foregroundColor(themeManager.preferedThemes.contains(theme) ? .white : .init(uiColor14: .label) )
        }
        .padding(10)
        .background(Color(uiColor14: .secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            icons = (try? themeManager.icons(forAppIDs: ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"], from: theme)) ?? []
        }
    }
    
    @ViewBuilder
    var noIconsFoundPreview: some View {
        Text("Not enough icons to show a preview. \nInvalid theme?")
            .multilineTextAlignment(.center)
            .padding(6)
            .background(MaterialView(.dark))
            .foregroundColor(.white)
            .font(.footnote)
            .cornerRadius(4)
            .padding(6)
        
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView(theme: Theme(name: "Theme", iconCount: 23), wallpaper: UIImage(named: "wallpaper")!)
            .frame(width: 190)
            .preferredColorScheme(.dark)
    }
}
