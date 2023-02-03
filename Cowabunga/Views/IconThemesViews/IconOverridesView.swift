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
                        .onAppear {
                            remLog(app.appID, themeManager.iconOverrides[app.appID])
                        }
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
        allApps = LSApplicationWorkspace.default().allApplications().compactMap {
            if Dynamic($0).appTags.asArray?.contains("hidden") ?? true
                || $0.isRestricted
                || Dynamic($0).isLaunchProhibited.asBool ?? false
                || (Bundle(url: $0.bundleURL)?.object(forInfoDictionaryKey: "SBAppTags") as? NSArray)?.contains("hidden") ?? false
            { return nil }
            if let themedIcon = preferedIcons[$0.applicationIdentifier] {
                return IconOverrideViewApp(appID: $0.bundleIdentifier,
                                           icon: UIImage(contentsOfFile: themedIcon.themeIconURL.path), displayName: $0.localizedName())
            } else {
                return IconOverrideViewApp(appID: $0.bundleIdentifier,
                             icon: Dynamic(UIImage.self)._applicationIconImage(forBundleIdentifier: $0.bundleIdentifier,
                                                                               format: 1,
                                                                               scale: 4.0).asAnyObject as? UIImage, displayName: $0.localizedName())
            }
        }
        remLog("update")
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
