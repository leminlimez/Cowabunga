//
//  AltIconSelectionView.swift
//  TrollTools
//
//  Created by exerhythm on 28.10.2022.
//

import SwiftUI

struct AltIconSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State var bundleID: String
    @State var displayName: String
    @Environment(\.presentationMode) var presentation
    var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100))]
    
    var onChoose: (String) -> ()
    @State var icons: [(UIImage, String)] = []
    
    var body: some View {
        Group {
            if icons.count == 0 {
                Text("No themes containing icons for \(displayName) (\(bundleID)) have been found.")
                    .padding()
                    .background(Color(uiColor14: .secondarySystemBackground))
                    .multilineTextAlignment(.center)
                    .cornerRadius(16)
                    .font(.footnote)
                    .foregroundColor(Color(uiColor14: .secondaryLabel))
            } else {
                LazyVGrid(columns: gridItemLayout, spacing: 14) {
                    ForEach(icons, id: \.1) { (icon, themeName) in
                        Button(action: {
                            onChoose(themeName)
                            presentation.wrappedValue.dismiss()
                        }) {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .cornerRadius(25)
                        }
                    }
                }
            }
        }
        .navigationTitle(displayName)
        .onAppear {
            for t in themeManager.themes {
                if let icon = try? themeManager.icon(forAppID: bundleID, from: t) {
                    icons.append((icon, t.name))
                }
            }
        }
    }
}
