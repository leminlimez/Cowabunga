//
//  RootView.swift
//  Cowabunga
//
//  Created by lemin on 1/6/23.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
//            SpringBoardView()
//                .tabItem {
//                    Label("SpringBoard", systemImage: "snowflake")
//                }
            AudioView()
                .tabItem {
                    Label("Audio", systemImage: "speaker.wave.2.fill")
                }
            ExploreView()
                .tabItem {
                    Label("Themes", systemImage: "sparkles")
                }
//            PasscodeEditorView()
//                .tabItem {
//                    Label("Passcode", systemImage: "key")
//                }
//            LockView()
//                .tabItem {
//                    Label("Lock", systemImage: "lock")
//                }
//            OtherModsView()
//                .tabItem {
//                    Label("Misc.", systemImage: "hammer")
//                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
