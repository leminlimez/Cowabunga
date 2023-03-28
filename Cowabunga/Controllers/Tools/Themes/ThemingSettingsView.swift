//
//  ThemingSettingsView.swift
//  Cowabunga
//
//  Created by sourcelocation on 14/03/2023.
//

import SwiftUI

struct ThemingSettingsView: View {
    
    @AppStorage("catalogIconTheming") var catalogIconTheming = false
    @AppStorage("pngIconTheming") var pngIconTheming = false
    @AppStorage("showCancelButtonOnThemingEnd") var showCancelButtonOnThemingEnd = false
    @AppStorage("noThemingFixup") var noThemingFixup = false
    @AppStorage("noPNGThemingFixup") var noPNGThemingFixup = false
    @AppStorage("noCatalogThemingFixup") var noCatalogThemingFixup = false
    
    var body: some View {
        List {
            Toggle(isOn: $catalogIconTheming) {
                Text("Catalog Icon Theming (v10 method)")
            }
            Toggle(isOn: $pngIconTheming) {
                Text("PNG Icon Theming (v8 method)")
            }
            Toggle(isOn: $showCancelButtonOnThemingEnd) {
                Text("showCancelButtonOnThemingEnd")
            }
            Toggle(isOn: $noThemingFixup) {
                Text("Disable Theming Fixup")
            }
            Toggle(isOn: $noPNGThemingFixup) {
                Text("Disable PNG Theming Fixup (Stop Random Reverts)")
            }
        }
    }
}

struct ThemingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemingSettingsView()
    }
}
