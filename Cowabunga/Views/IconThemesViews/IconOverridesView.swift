//
//  IndividualIconsEditorView.swift
//  TrollTools
//
//  Created by exerhythm on 28.10.2022.
//

import SwiftUI
//import LaunchServicesBridge
import Dynamic

@available(iOS 15.0, *)
struct IconOverridesView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    var gridItemLayout = [GridItem(.adaptive(minimum: 64, maximum: 64))]
    @State private var searchText = ""
    
    @State var allApps: [IconOverrideViewApp] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 14) {
                ForEach(allApps, id: \.self) { app in
                    if searchText == "" || app.displayName.contains(searchText) {
                        IconEditorAppView(app: app, edited: themeManager.iconOverrides[app.appID] != nil, updateApps: updateApps)
                            .padding(.horizontal, 3)
                    }
                }
            }
            .padding(.bottom, 80)
        }
        .searchable(text: $searchText)
        .navigationTitle("Icons override")
        .onAppear {
            updateApps()
        }
    }
    
    func updateApps() {
        do {
            let preferedIcons = themeManager.preferedIcons
            allApps = try ApplicationManager.getApps().filter({ !$0.hiddenFromSpringboard }).sorted(by: { $0.name.lowercased() < $1.name.lowercased() }).map {
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
        } catch {
            UIApplication.shared.confirmAlert(title: "Fatal Error!", body: "The apps could not be found! \(error.localizedDescription)", onOK: {
                exit(0)
            }, noCancel: true)
        }
    }
    
    struct IconEditorAppView: View {
        @ObservedObject var themeManager = ThemeManager.shared
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
