//
//  IndividualIconsEditorView.swift
//  TrollTools
//
//  Created by exerhythm on 28.10.2022.
//

import SwiftUI
//import LaunchServicesBridge
import Dynamic

struct IconOverridesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var gridItemLayout = [GridItem(.adaptive(minimum: 64, maximum: 64))]
    
    @State var allApps: [IconOverrideViewApp] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 14) {
                ForEach(allApps, id: \.self) { app in
                    IconEditorAppView(app: app, edited: themeManager.iconOverrides[app.appID] != nil, updateApps: updateApps)
                        .padding(.horizontal, 3)
                }
            }
            .padding(.bottom, 80)
        }
        .navigationTitle("Icons override")
        .onAppear {
            updateApps()
        }
    }
    
    func updateApps() {
        let preferedIcons = themeManager.preferedIcons
        allApps = try! ApplicationManager.getApps().filter({ !$0.hiddenFromSpringboard }).map {
            if let themedIcon = preferedIcons[$0.bundleIdentifier] {
                return IconOverrideViewApp(appID: $0.bundleIdentifier,
                                           icon: UIImage(contentsOfFile: themedIcon.rawThemeIconURL.path), displayName: $0.name)
            } else {
                return IconOverrideViewApp(appID: $0.bundleIdentifier,
                             icon: Dynamic(UIImage.self)._applicationIconImage(forBundleIdentifier: $0.bundleIdentifier,
                                                                               format: 1,
                                                                               scale: 4.0).asAnyObject as? UIImage, displayName: $0.name)
            }
        }
    }
    
    struct IconEditorAppView: View {
        @EnvironmentObject var themeManager: ThemeManager
        @State var app: IconOverrideViewApp
        @State var edited: Bool
        //        @State var actionSheetPresented = false
        @State var showsAltSelectionSheet = false
        
        var updateApps: () -> ()
        
        var body: some View {
            if !edited {
                NavigationLink(destination: AltIconSelectionView(bundleID: app.appID, displayName: app.displayName, onChoose: { name in
                    themeManager.iconOverrides[app.appID] = name
                    edited = true
                    updateApps()
                })) {
                    iconContent
                }
            } else {
                Button(action: {
                    themeManager.iconOverrides[app.appID] = nil
                    edited = false
                    updateApps()
                }) {
                    iconContent
                }
            }
//            .actionSheet(isPresented: $actionSheetPresented) {
//                ActionSheet(title: Text("Custom icon"), buttons: [
//                    .cancel(),
//                    .default(Text("Alternative icons"), action: {
//                    }),
//                    .default(Text("Choose from photos"))
//                ])
//            }
        }
        
        @ViewBuilder
        var iconContent: some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: app.icon ?? UIImage(named: "NotFound")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                if edited {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.init(uiColor14: .systemBackground))
                        .padding(5)
                        .background(Color.accentColor)
                        .cornerRadius(.infinity)
                        .font(.system(size: 13))
                        .offset(x: 7, y: -7)
                }
            }
        }
    }
    
    struct IconOverrideViewApp: Hashable {
        var appID: String
        var icon: UIImage?
        var displayName: String
    }

}

//struct IndividualIconsEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        IconOverridesView(editedApps: [])
//    }
//}
