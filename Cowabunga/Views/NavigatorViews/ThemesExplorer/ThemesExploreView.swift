//
//  ExploreView.swift
//  Cowabunga
//
//  Created by sourcelocation on 30/01/2023.
//

import SwiftUI
import CachedAsyncImage

@available(iOS 15.0, *)
struct ThemesExploreView: View {
    
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
                    ScrollView {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                            // refresh
                            themes.removeAll()
                            //URLCache.imageCache.removeAllCachedResponses()
                            loadThemes()
                        }
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
                                        let themeTask = URLSession.shared.dataTask(with: theme.url) { data, response, error in
                                            guard let data = data else {
                                                print("No data found!")
                                                UIApplication.shared.dismissAlert(animated: true)
                                                UIApplication.shared.alert(title: "Could not download passcode theme!", body: error?.localizedDescription ?? "Unknown Error")
                                                return
                                            }
                                            do {
                                                try data.write(to: themeSaveURL)
                                            } catch {
                                                print("Could not save data to theme save url!")
                                                UIApplication.shared.dismissAlert(animated: true)
                                                UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
                                                return
                                            }
                                            
                                            // save the preview file
                                            let previewSaveURL = saveURL.appendingPathComponent("preview.png")
                                            let task = URLSession.shared.dataTask(with: theme.preview) { prevData, prevResponse, prevError in
                                                guard let prevData = prevData else {
                                                    print("No data found!")
                                                    UIApplication.shared.dismissAlert(animated: true)
                                                    UIApplication.shared.alert(title: "Could not download passcode theme!", body: prevError?.localizedDescription ?? "Unknown Error")
                                                    return
                                                }
                                                do {
                                                    try prevData.write(to: previewSaveURL)
                                                    UIApplication.shared.dismissAlert(animated: true)
                                                    UIApplication.shared.alert(title: "Successfully saved passcode theme!", body: "You can use it by tapping the import button in the Passcode Editor and tapping \"Saved\".")
                                                } catch {
                                                    print("Could not save data to preview url!")
                                                    UIApplication.shared.dismissAlert(animated: true)
                                                    UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
                                                    return
                                                }
                                            }
                                            task.resume()
                                        }
                                        themeTask.resume()
                                    } catch {
                                        print("Could not download passcode theme: \(error.localizedDescription)")
                                        UIApplication.shared.dismissAlert(animated: true)
                                        UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
                                    }
                                } label: {
                                    VStack(spacing: 0) {
                                        CachedAsyncImage(url: theme.preview, urlCache: .imageCache) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 170, height: 250)
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
                                .background(Color(uiColor14: .secondarySystemBackground))
                                .cornerRadius(10)
                                .padding(4)
                            }
                        }
                        .padding()
                    }
                    .coordinateSpace(name: "pullToRefresh")
                    .navigationTitle("Explore")
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
            loadThemes()
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
    
    func loadThemes() {
        Task {
            do {
                themes = try await cowabungaAPI.fetchPasscodeThemes().shuffled()
            } catch {
                UIApplication.shared.alert(body: "Error occured while fetching themes. \(error.localizedDescription)")
            }
        }
    }
}

struct PullToRefresh: View {
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("")
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

@available(iOS 15.0, *)
struct ThemesExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesExploreView()
            .environmentObject(CowabungaAPI())
    }
}
