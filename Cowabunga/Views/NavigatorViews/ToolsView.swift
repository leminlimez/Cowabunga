//
//  ToolsView.swift
//  Cowabunga
//
//  Created by lemin on 1/27/23.
//
// Most of the credit goes to TrollTools for this

import SwiftUI

struct ToolsView: View {
    struct SpringboardOption: Identifiable {
        var value: Bool
        var id = UUID()
        var key: String
        var title: String
        var imageName: String
    }
    
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
        var options: [GeneralOption]
    }
    
    @State var springboardOptions: [SpringboardOption] = [
        .init(value: false, key: "SBShowRSSI", title: "Numeric Wi-Fi Strength", imageName: "wifi"),
        .init(value: false, key: "SBShowGSMRSSI", title: "Numeric Cellular Strength", imageName: "antenna.radiowaves.left.and.right"),
        .init(value: false, key: "SBDontDimOrLockOnAC", title: "Don't dim when charging", imageName: "battery.100.bolt"),
        .init(value: false, key: "SBHideLowPowerAlerts", title: "No Low Battery alerts", imageName: "battery.25"),
        .init(value: false, key: "SBDisableHomeButton", title: "Disable Home Button", imageName: "iphone.homebutton"),
        .init(value: false, key: "SBDontLockEver", title: "Disable Lock Button", imageName: "lock.square"),
        .init(value: false, key: "SBDisableNotificationCenterBlur", title: "Disable Notif Center Blur", imageName: "app.badge"),
        .init(value: false, key: "SBControlCenterEnabledInLockScreen", title: "Lock Screen CC", imageName: "square.grid.2x2"),
        .init(value: false, key: "SBControlCenterDemo", title: "CC AirPlay Radar", imageName: "wifi.circle"),
    ]
    
    @State var toolsCategories: [ToolsCategory] = [
        .init(title: "Home Screen", options: [
            .init(key: "SpringBoardView", view: AnyView(SpringBoardView()), title: "Springboard Tools", imageName: "snowflake"),
            .init(key: "SpringboardColorChangerView", view: AnyView(SpringboardColorChangerView()), title: "Badge Changer", imageName: "app.badge", ios15Only: true)
        ]),
        .init(title: "Lock Screen", options: [
            .init(key: "PasscodeEditorView", view: AnyView(PasscodeEditorView()), title: "Passcode Faces", imageName: "ellipsis.rectangle"),
            .init(key: "LockView", view: AnyView(LockView()), title: "Locks", imageName: "lock"),
            .init(key: "LSFootnoteChangerView", view: AnyView(LSFootnoteChangerView()), title: "Lock Screen Footnote", imageName: "iphone")
        ]),
        .init(title: "Other", options: [
            .init(key: "StatusBarView", view: AnyView(StatusBarView()), title: "Status Bar", imageName: "wifi"),
            .init(key: "MainCardView", view: AnyView(MainCardView()), title: "Card Changer", imageName: "creditcard"),
            .init(key: "OtherModsView", view: AnyView(OtherModsView()), title: "Miscellaneous", imageName: "hammer")
        ])
    ]
    @State var iOS16: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($toolsCategories) { cat in
                    Section {
                        ForEach(cat.options) { option in
                            if !option.ios15Only.wrappedValue || !iOS16 {
                                NavigationLink(destination: option.view.wrappedValue, isActive: option.active) {
                                    HStack {
                                        Image(systemName: option.imageName.wrappedValue)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.blue)
                                        Text(option.title.wrappedValue)
                                            .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(cat.title.wrappedValue)
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
                for (i, option) in springboardOptions.enumerated() {
                    springboardOptions[i].value = getSpringboardOption(key: option.key) as? Bool ?? false
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
