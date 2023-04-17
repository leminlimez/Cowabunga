//
//  SearchBar.swift
//  DirtyJIT
//
//  Created by Анохин Юрий on 05.03.2023.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(.systemGray6))
                    .cornerRadius(10)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                    TextField("Search", text: $text, onEditingChanged: { editing in
                        self.isEditing = editing
                    })
                    .foregroundColor(.primary)
                    .accentColor(.primary)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.trailing, isEditing ? 0 : 32)
                    .frame(height: 36)
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            self.text = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    }
                }
            }
            .frame(height: 36)
            .padding(.horizontal, 10)
        }
    }
}
