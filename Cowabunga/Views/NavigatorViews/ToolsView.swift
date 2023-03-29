//
//  ToolsView.swift
//  Cowabunga
//
//  Created by lemin on 1/27/23.
//
// Most of the credit goes to TrollTools for this

import SwiftUI

struct ToolsView: View {
    struct GeneralOption: Identifiable {
        var key: String
        var id = UUID()
        var view: AnyView
        var title: String
        var imageName: String
        var active: Bool = false
        var ios15Only: Bool = false
    }
    
    struct ToolsCategory: Identifiable {
        var id = UUID()
        var title: String
        var systemImage: String
        var options: [GeneralOption]
    }
    
    private var machineName = UIDevice().machineName
    
    @State var toolsCategories: [ToolsCategory] = [
        .init(title: NSLocalizedString("Advanced", comment: "Category of tool"), systemImage: "gearshape.2", options: [
            .init(key: "AdvancedView", view: AnyView(AdvancedView()), title: NSLocalizedString("Custom Operations", comment: "Title of tool"), imageName: "pencil.and.outline")
        ]),
        .init(title: NSLocalizedString("Springboard", comment: "Category of tool"), systemImage: "square.grid.2x2", options: [
            .init(key: "SpringBoardView", view: AnyView(SpringBoardView()), title: NSLocalizedString("Springboard Tools", comment: "Title of tool"), imageName: "snowflake"),
            .init(key: "SpringboardColorChangerView", view: AnyView(SpringboardColorChangerView()), title: NSLocalizedString("Badge Colors", comment: "Title of tool"), imageName: "app.badge", ios15Only: true),
            .init(key: "MainFontsView", view: AnyView(MainFontsView()), title: NSLocalizedString("Fonts", comment: "Title of tool"), imageName: "f.cursive")
        ]),
        .init(title: NSLocalizedString("Lock Screen", comment: "Category of tool"), systemImage: "lock", options: [
            .init(key: "PasscodeEditorView", view: AnyView(PasscodeEditorView()), title: NSLocalizedString("Passcode Faces", comment: "Title of tool"), imageName: "ellipsis.rectangle"),
            .init(key: "LockView", view: AnyView(LockView()), title: NSLocalizedString("Locks", comment: "Title of tool"), imageName: "lock"),
            .init(key: "LSFootnoteChangerView", view: AnyView(LSFootnoteChangerView()), title: NSLocalizedString("Lock Screen Footnote", comment: "Title of tool"), imageName: "iphone")
        ]),
        .init(title: NSLocalizedString("Control Center", comment: "Category of tool"), systemImage: "switch.2", options: [
            .init(key: "StatusBarView", view: AnyView(StatusBarView()), title: NSLocalizedString("Status Bar", comment: "Title of tool"), imageName: "wifi")
        ]),
        .init(title: NSLocalizedString("Apps", comment: "Category of tool"), systemImage: "app", options: [
            .init(key: "CalculatorErrorView", view: AnyView(CalculatorErrorView()), title: NSLocalizedString("Calculator Error Message", comment: "Title of tool"), imageName: "function"),
            .init(key: "SettingsCustomizerView", view: AnyView(SettingsCustomizerView()), title: NSLocalizedString("Settings App Customizer", comment: "Title of tool"), imageName: "gear")
        ]),
        .init(title: NSLocalizedString("Other", comment: "Category of tool"), systemImage: "ellipsis", options: [
            .init(key: "AudioView", view: AnyView(AudioView()), title: NSLocalizedString("Audio", comment: "Title of tool"), imageName: "speaker.wave.2.fill"),
            .init(key: "MainCardView", view: AnyView(MainCardView()), title: NSLocalizedString("Card Changer", comment: "Title of tool"), imageName: "creditcard"),
            .init(key: "WhitelistView", view: AnyView(WhitelistView()), title: NSLocalizedString("Whitelist", comment: "Title of tool"), imageName: "app.badge.checkmark"),
            .init(key: "FreeloadView", view: AnyView(FreeloadView()), title: NSLocalizedString("Remove three-app limit", comment: "Title of tool"), imageName: "apps.iphone.badge.plus"),
            .init(key: "OtherModsView", view: AnyView(OtherModsView()), title: NSLocalizedString("Miscellaneous", comment: "Title of tool"), imageName: "hammer")
        ])
    ]
    @State var iOS16: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($toolsCategories) { cat in
                    Section {
                        ForEach(cat.options) { option in
                            if (!option.ios15Only.wrappedValue || !iOS16) && (!(option.key.wrappedValue == "LockView") || LockManager.deviceLockPath[machineName] != nil) {
                                NavigationLink(destination: option.view.wrappedValue, isActive: option.active) {
                                    HStack {
                                        Image(systemName: option.imageName.wrappedValue)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.blue)
                                        Text(NSLocalizedString(option.title.wrappedValue, comment: "A tools option"))
                                            .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                    } header: {
                        Label(cat.title.wrappedValue, systemImage: cat.systemImage.wrappedValue)
                    }
                }
                
                /*Section {
                    ForEach($springboardOptions) { option in
                        HStack {
                            Image(systemName: option.imageName.wrappedValue)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            
                            Toggle(isOn: option.value) {
                                Text(option.title.wrappedValue)
                                    .minimumScaleFactor(0.5)
                            }.onChange(of: option.value.wrappedValue) { new in
                                do {
                                    try toggleSpringboardOption(key: option.key.wrappedValue, value: new)
                                } catch {
                                    UIApplication.shared.alert(body: "\(error.localizedDescription)")
                                }
                            }
                            .padding(.leading, 10)
                        }
                    }
                } header: {
                    Text("Experimental")
                } footer: {
                    Text("Last 5 options are not guaranteed to work")
                }*/
            }
            .navigationTitle("Tools")
            .onAppear {
                if #available(iOS 16, *) {
                    iOS16 = true
                }
            }
        }
    }
    
    func getSpringboardOption(key: String) -> Any? {
        let url = URL(fileURLWithPath: "/var/preferences/com.apple.springboard.plist")
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any]
        
        return plist?[key]
    }
    
    func toggleSpringboardOption(key: String, value: Any) throws {
        let url = URL(fileURLWithPath: "/var/preferences/com.apple.springboard.plist")
        
        var plistData: Data
        if !FileManager.default.fileExists(atPath: url.path) {
            plistData = try PropertyListSerialization.data(fromPropertyList: [key: value], format: .xml, options: 0)
        } else {
            guard let data = try? Data(contentsOf: url), var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Couldn't read com.apple.springboard.plist" }
            plist[key] = value
            
            // Save plist
            plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        }
        
        // write to file
        do {
            try plistData.write(to: url)
        } catch {
            print("error replacing plist")
            UIApplication.shared.alert(body: "Could not replace springboard option!")
        }
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
