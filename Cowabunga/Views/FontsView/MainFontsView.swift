//
//  MainFontsView.swift
//  Cowabunga
//
//  Created by lemin on 2/16/23.
//

import SwiftUI

struct MainFontsView: View {
    struct FontReplacement: Identifiable {
        var id = UUID()
        var title: String
    }
    
    @State private var fontOptions: [FontReplacement] = [
        .init(title: "Basic Fonts")
    ]
    
    var body: some View {
        VStack {
            List {
                ForEach($fontOptions) { option in
                    HStack {
                        Text(option.title.wrappedValue)
                            .padding(.horizontal, 8)
                        Spacer()
                        Text("Default")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
