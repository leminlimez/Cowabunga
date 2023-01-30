//
//  ExploreView.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import SwiftUI

struct ExploreView: View {
    // lazyvgrid
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    @State private var themes: [DownloadableTheme] = []
    
    var body: some View {
        NavigationView {
            if themes.isEmpty {
                ProgressView()
            } else {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach($themes) { theme in
                        Button(action: {
                            print("Downloading from \(theme.downloadURL)")
                        }) {
                            
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
            }
        }
        
//            .sheet(isPresented: $showLogin, content: { LoginView() })
        // maybe later
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
