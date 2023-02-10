//
//  IconThemeFinishView.swift
//  Cowabunga
//
//  Created by sourcelocation on 10/02/2023.
//

import SwiftUI

@available(iOS 15.0, *)
struct CatalogFixupView: View {
    @State private var isRotating = 0.0
    @State var showSuccess = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                if showSuccess {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isRotating))
                        .onTapGesture {
                            withAnimation(.linear(duration: 1)
                                    .speed(0.2).repeatForever(autoreverses: false)) {
                                isRotating = 3600
                            }
                        }
                } else {
                    Image(systemName: "gear")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isRotating / 2))
                    Image(systemName: "gear")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-isRotating))
                        .opacity(0.25)
                }
            }
            Text(showSuccess ? "Success" : "Fixing apps...")
                .font(.system(size: 24, weight: .bold))
                .padding(.vertical, 2)
                .padding(.horizontal, 64)
            
            
            Text(showSuccess ? "Your apps should now function properly" : "Please wait for Cowabunga to finish theming...")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 64)
            
                Spacer()
            if !showSuccess { Text("In the meantime you can ...", comment: "A joke about users being able to join Discord while they wait for Cowabunga to finish theming. \"In the meantime you can Join Discord\" is the text for button") }
            Button("Join Discord") {
                UIApplication.shared.open(URL(string: "https://discord.gg/zTPFJuQfdw")!)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 64)
            
            if showSuccess {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1)
                    .speed(0.2).repeatForever(autoreverses: false)) {
                isRotating = 360
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                do {
                    try CatalogThemeManager.uncorruptCatalogs()
                    UserDefaults.standard.set(false, forKey: "shouldPerformCatalogFixup")
                    showSuccess = true
                    isRotating = 0
                } catch {
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            })
        }
        .interactiveDismissDisabled(!showSuccess)
    }
}

@available(iOS 15.0, *)
struct IconThemeFinishView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogFixupView()
    }
}
