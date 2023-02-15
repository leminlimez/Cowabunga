//
//  TintedButton14.swift
//  Cowabunga
//
//  Created by sourcelocation on 31/01/2023.
//

import SwiftUI

struct FullwidthTintedButton: ButtonStyle {
    var color: Color
    var info: String?
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(color.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(color)
            
            if let info = info {
                HStack {
                    Spacer()
                    Button {
                        UIApplication.shared.alert(title: "Info", body: info)
                    } label: {
                        Image(systemName: "info")
                            .frame(width: 32, height: 32)
                            .background(MaterialView(.systemChromeMaterial))
                            .cornerRadius(10)
                            .foregroundColor(color)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
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


#if DEBUG
@available(iOS 15, *)
struct FullwidthTintedButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Exaple") {
            
        }
        .buttonStyle( FullwidthTintedButton(color: .red, info: "Test info"))
        .padding()
    }
}
#endif
