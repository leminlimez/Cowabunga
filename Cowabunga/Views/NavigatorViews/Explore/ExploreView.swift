//
//  ExploreView.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import SwiftUI

@available(iOS 15.0, *)
struct ExploreView: View {
    
    @EnvironmentObject var cowabungaAPI: CowabungaAPI
    // lazyvgrid
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    @State private var themes: [DownloadableTheme] = []
    
    var body: some View {
        NavigationView {
            if themes.isEmpty {
                ProgressView()
            } else {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(themes) { theme in
                        Button {
                            print("Downloading from \(theme.url.absoluteString)")
                        } label: {
                            VStack {
                                Text(theme.name)
                                AsyncImage(url: theme.preview) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.gray
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            Task {
                do {
                    themes = try await cowabungaAPI.fetchPasscodeThemes()
                } catch {
                    UIApplication.shared.alert(body: "Error occured while fetching themes. \(error.localizedDescription)")
                }
            }
        }
        
//            .sheet(isPresented: $showLogin, content: { LoginView() })
        // maybe later
    }
}

@available(iOS 15.0, *)
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
