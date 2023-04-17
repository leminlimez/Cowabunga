//
//  AppsView.swift
//  DirtyJIT
//
//  Created by Анохин Юрий on 05.03.2023.
//

import SwiftUI

struct AppsView: View {
    @Binding var searchText: String
    let apps2: [SBApp2]
    let appsManager2 = ApplicationManager2.shared
    let jit = JIT.shared
    
    var body: some View {
        List(apps2.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }) { app2 in
            HStack {
                if let image = UIImage(contentsOfFile: app2.bundleURL.appendingPathComponent(app2.pngIconPaths.first ?? "").path) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .cornerRadius(10)
                } else {
                    Image("DefaultIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .cornerRadius(10)
                }
                VStack(alignment: .leading) {
                    Text(app2.name)
                        .font(.headline)
                    Text(app2.bundleIdentifier)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                UIApplication.shared.confirmAlert(title: "Warning", body: "We will now try to enable JIT on \(app2.name). Make sure the app is opened in the background so we can find it's PID!", onOK: {
                    UIApplication.shared.alert(title: "Please wait", body: "Enabling JIT...", withButton: false)
                    
                    callps()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        UIApplication.shared.dismissAlert(animated: true)
                        
                        jit.enableJIT(pidApp: jit.returnPID(exec: app2.name))
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            appsManager2.openApp(app2.bundleIdentifier)
                        }
                    }
                }, noCancel: false)
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
    }
}
