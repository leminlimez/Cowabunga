//
//  IconThemeFinishView.swift
//  Cowabunga
//
//  Created by sourcelocation on 10/02/2023.
//

import SwiftUI
import MacDirtyCowSwift

var ERRORED_APP: String = "UNKNOWN"

@available(iOS 15.0, *)
struct CatalogFixupView: View {
    @State private var isRotating1 = 0.0
    @State private var isRotating2 = 0.0
    
    @State var percentage = 0.0
    @State var showSuccess = false
    
    @Environment(\.dismiss) var dismiss
    
    @State var restartRequired = UIImage(named: "wallpaper") == nil
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                if showSuccess {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isRotating1))
                        .onTapGesture {
                            withAnimation(.linear(duration: 1)
                                    .speed(0.2).repeatForever(autoreverses: false)) {
                                isRotating1 = 3600
                            }
                        }
                } else {
                    Image(systemName: "gear")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isRotating1))
                    Image(systemName: "gear")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-isRotating2))
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
            
            ProgressView("", value: percentage, total: 1)
                .labelsHidden()
                .padding(.horizontal, 64)
            
            Spacer()
            if !showSuccess { Text("In the meantime you can ...", comment: "A joke about users being able to join Discord while they wait for Cowabunga to finish theming. \"In the meantime you can Join Discord\" is the text for button") }
            Button("Join Discord") {
                UIApplication.shared.open(URL(string: "https://discord.gg/zTPFJuQfdw")!)
            }
            .buttonStyle(TintedButton(color: .gray, fullwidth: true))
            .padding(8)
            .padding(.horizontal, 32)
            
            if showSuccess {
                Button("Close") {
                    if !restartRequired {
                        dismiss()
                    } else {
                        UIApplication.shared.confirmAlert(title: "App restart required", body: "You've applied a theme which contains an icon for Cowabunga itself. Please restart for app to work.", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                }
                .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                .padding(.horizontal, 40)
            }
            Spacer()
        }
        .onAppear {
            withAnimation(.linear(duration: 1)
                    .speed(0.2).repeatForever(autoreverses: false)) {
                isRotating1 = 360
            }
            withAnimation(.linear(duration: 1)
                    .speed(0.1).repeatForever(autoreverses: false)) {
                isRotating2 = 360
            }
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1, execute: {
                do {
                    var errorsCatalog: [String] = []
                    
                    let noCatalogThemingFixup = UserDefaults.standard.bool(forKey: "noCatalogThemingFixup")
                    
                    if !noCatalogThemingFixup {
                        errorsCatalog = try CatalogThemeManager.restoreCatalogs(progress: { (percentage, app) in
                            self.percentage = percentage
                        })
                    }
                    
                    UserDefaults.standard.set(false, forKey: "shouldPerformCatalogFixup")
                    showSuccess = true
                    isRotating1 = 0
                    
                    if !errorsCatalog.isEmpty {
                        UIApplication.shared.alert(body: (errorsCatalog).joined(separator: "\n\n"))
                    }
                } catch {
                    if MDC.isMDCSafe {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    } else {
                        UIApplication.shared.alert(body: "⛔️ Aborted ⛔️\n\n\(error.localizedDescription)\n\nError occurred with: \(ERRORED_APP)", withButton: false)
                    }
                }
            })
        }
        .interactiveDismissDisabled(!showSuccess || restartRequired)
    }
}

@available(iOS 15.0, *)
struct IconThemeFinishView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogFixupView()
    }
}
