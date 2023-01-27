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
            SpringBoardView()
                .tabItem {
                    Label("SpringBoard", systemImage: "snowflake")
                }
            AudioView()
                .tabItem {
                    Label("Audio", systemImage: "speaker.wave.2.fill")
                }
            LockView()
                .tabItem {
                    Label("Lock", systemImage: "lock")
                }
            OtherModsView()
                .tabItem {
                    Label("Misc.", systemImage: "hammer")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
