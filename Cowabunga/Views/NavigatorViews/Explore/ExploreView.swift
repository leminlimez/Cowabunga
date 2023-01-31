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
    
    @State var submitThemeAlertShown = false
    
    var body: some View {
        NavigationView {
            if themes.isEmpty {
                ProgressView()
            } else {
                ZStack {
                    Color(uiColor14: .secondarySystemBackground).edgesIgnoringSafeArea(.all)
                    ScrollView {
                        Text("This is a demo. Doesn't currently work")
                            .multilineTextAlignment(.center)
                        LazyVGrid(columns: gridItemLayout) {
                            ForEach(themes) { theme in
                                Button {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    print("Downloading from \(theme.url.absoluteString)")
                                    UIApplication.shared.alert(title: "Downloading \(theme.name)...", body: "Please wait", animated: false, withButton: false)
                                    
                                    // create the folder
                                    do {
                                        let saveURL = PasscodeKeyFaceManager.getPasscodesDirectory()!.appendingPathComponent(theme.name.replacingOccurrences(of: " ", with: "_"))
                                        if !FileManager.default.fileExists(atPath: saveURL.path) {
                                            try FileManager.default.createDirectory(at: saveURL, withIntermediateDirectories: false)
                                        }
                                        
                                        // save the passthm file
                                        let themeSaveURL = saveURL.appendingPathComponent("theme.passthm")
                                        let sessionConfig = URLSessionConfiguration.default
                                        let session = URLSession(configuration: sessionConfig)
                                        let request = URLRequest(url: theme.url)
                                    } catch {
                                        print("Could not download passcode theme: \(error.localizedDescription)")
                                        UIApplication.shared.dismissAlert(animated: true)
                                        UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
                                    }
                                } label: {
                                    VStack(spacing: 0) {
                                        AsyncImage(url: theme.preview) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .cornerRadius(10, corners: .topLeft)
                                                .cornerRadius(10, corners: .topRight)
                                        } placeholder: {
                                            Color.gray
                                        }
                                        HStack {
                                            VStack(spacing: 4) {
                                                HStack {
                                                    Text(theme.name)
                                                        .foregroundColor(Color(uiColor14: .label))
                                                        .minimumScaleFactor(0.5)
                                                    Spacer()
                                                }
                                                HStack {
                                                    Text(theme.contact.values.first ?? "Unknown author")
                                                        .foregroundColor(.secondary)
                                                        .font(.caption)
                                                        .minimumScaleFactor(0.5)
                                                    Spacer()
                                                }
                                            }
                                            .lineLimit(1)
                                            Spacer()
                                            Image(systemName: "arrow.down.circle")
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(height: 58)
                                    }
                                }
                                .background(Color(uiColor14: .systemBackground))
                                .cornerRadius(10)
                                .padding(4)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Themes")
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            submitThemeAlertShown = true
                        } label: {
                            Image(systemName: "paperplane")
                        }
                    }
                }
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
        .alert("Submit themes", isPresented: $submitThemeAlertShown, actions: {
            Button("Join Discord", role: .none, action: {
                UIApplication.shared.open(URL(string: "https://discord.gg/zTPFJuQfdw")!)
            })
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text("Currently to submit themes for other people to see and use, we have to review them on our Discord in #showcase channel.")

        })
//            .sheet(isPresented: $showLogin, content: { LoginView() })
        // maybe later
    }
}

@available(iOS 15.0, *)
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(CowabungaAPI())
    }
}
