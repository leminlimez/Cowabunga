//
//  MainFontsView.swift
//  Cowabunga
//
//  Created by lemin on 2/16/23.
//

import SwiftUI

struct FontPack: Identifiable {
    var id = UUID()
    var name: String
    var enabled: Bool = false
}

struct MainFontsView: View {
    @State private var fontOptions: [FontPack] = [
        .init(name: "None", enabled: true)
    ]
    
    var body: some View {
        VStack {
            List {
                ForEach($fontOptions) { option in
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .opacity(option.enabled.wrappedValue ? 1 : 0)
                        Text(option.name.wrappedValue)
                            .padding(.horizontal, 8)
                    }
                }
            }
            .toolbar {
                Button(action: {
                    // create a new font pack
                }) {
                    Image(systemName: "plus")
                }
            }
            .onAppear {
                do {
                    fontOptions.append(contentsOf: try FontManager.getFontPacks())
                } catch {
                    UIApplication.shared.alert(title: NSLocalizedString("There was an error getting font packs.", comment: "loading font packs"), body: error.localizedDescription)
                }
            }
        }
    }
}
