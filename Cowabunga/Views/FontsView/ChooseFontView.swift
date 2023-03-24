//
//  ChooseFontView.swift
//  Cowabunga
//
//  Created by lemin on 3/10/23.
//

import SwiftUI

struct ChooseFontView: View {
    private struct FontFileType: Identifiable {
        var id = UUID()
        var title: String
        var file: String
    }
    
    @State private var fontFileTypes: [FontFileType] = [
        .init(title: "System Font", file: "SFUI.ttf"),
        .init(title: "Clock", file: "SFUISoft.ttc"),
        
        .init(title: "Other", file: "")
    ]
    
    var body: some View {
        VStack {
            Text("What font would you like to change?")
                .padding(.bottom, 2)
                .font(.title2)
            Text("Note: Fonts must be ported for iOS.")
                .font(.caption)
            List {
                ForEach($fontFileTypes) { font in
                    Button(action: {
                        
                    }) {
                        Text(font.title.wrappedValue + (font.file.wrappedValue == "" ? "" : " (\(font.file.wrappedValue))"))
                    }
                }
            }
        }
    }
}

struct ChooseFontView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseFontView()
    }
}
