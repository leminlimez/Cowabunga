//
//  TintedButton14.swift
//  Cowabunga
//
//  Created by sourcelocation on 31/01/2023.
//

import SwiftUI

struct FullwidthTintedButton: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(color)
    }
}

struct TintedButton: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .background(color.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(color)
    }
}
