//
//  TintedButton14.swift
//  Cowabunga
//
//  Created by sourcelocation on 31/01/2023.
//

import SwiftUI

struct TintedButton: ButtonStyle {
    var color: Color
    var material: UIBlurEffect.Style?
    var fullwidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if fullwidth {
                configuration.label
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(8)
                    .foregroundColor(color)
            } else {
                configuration.label
                    .padding(15)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(8)
                    .foregroundColor(color)
            }
        }
    }
    
    init(color: Color = .blue, fullwidth: Bool = false) {
        self.color = color
        self.fullwidth = fullwidth
    }
    init(color: Color = .blue, material: UIBlurEffect.Style, fullwidth: Bool = false) {
        self.color = color
        self.material = material
        self.fullwidth = fullwidth
    }
}


#if DEBUG
@available(iOS 15, *)
struct FullwidthTintedButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Exaple") {
            
        }
        .buttonStyle(TintedButton(color: .red, fullwidth: true))
        .padding()
    }
}
#endif
