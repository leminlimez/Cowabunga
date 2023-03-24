//
//  ThemingSettingsView.swift
//  Cowabunga
//
//  Created by sourcelocation on 14/03/2023.
//

import SwiftUI

struct ThemingSettingsView: View {
    
    @AppStorage("showCancelButtonOnThemingEnd") var showCancelButtonOnThemingEnd = false
    @AppStorage("noThemingFixup") var noThemingFixup = false
    
    var body: some View {
        List {
            Toggle(isOn: $showCancelButtonOnThemingEnd) {
                Text("showCancelButtonOnThemingEnd")
            }
            Toggle(isOn: $noThemingFixup) {
                Text("noThemingFixup")
            }
        }
    }
}

struct ThemingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemingSettingsView()
    }
}
