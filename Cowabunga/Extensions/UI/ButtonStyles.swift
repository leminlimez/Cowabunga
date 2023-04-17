//
//  ButtonStyles.swift
//  test
//
//  Created by Анохин Юрий on 25.01.2023.
//

import SwiftUI

public struct CustomButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                    .fill(Color.accentColor)
                )
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct LinkButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(Color.accentColor)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .fill(Color.accentColor)
                    .opacity(0.1)
            )
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct DangerButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.headline.weight(.bold))
            .padding(.vertical, 12)
            .foregroundColor(Color.red)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .fill(Color.red)
                    .opacity(0.1)
            )
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}
