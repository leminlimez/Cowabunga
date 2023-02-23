//
//  MainFontsView.swift
//  Cowabunga
//
//  Created by lemin on 2/16/23.
//

import SwiftUI

struct MainFontsView: View {
    struct FontPack: Identifiable {
        var id = UUID()
        var name: String
        var enabled: Bool = false
    }
    
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
        }
    }
}
