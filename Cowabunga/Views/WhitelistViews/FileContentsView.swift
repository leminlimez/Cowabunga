//
//  ContentsView.swift
//  Whitelist
//
//  Created by Hariz Shirazi on 2023-02-03.
//

import SwiftUI

struct FileContentsView: View {
    @State var blacklistContent = Whitelist.readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Does it even exist?"
    @State var bannedAppsContent = Whitelist.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Does it even exist?"
    @State var cdHashesContent = Whitelist.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Does it even exist?"
    
    var body: some View {
        if #available(iOS 15.0, *) {
            List {
                Section {
                    Text(blacklistContent)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Label("Blacklist", systemImage: "xmark.seal")
                }
                
                Section {
                    Text(bannedAppsContent)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Label("Banned Apps", systemImage: "xmark.app")
                }
                
                Section {
                    Text(cdHashesContent)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Label("CD Hashes", systemImage: "number.square")
                }
                
            }
            
            .refreshable {
                do {
                    Haptic.shared.play(.rigid)
                    refreshFiles()
                }
            }
            .navigationTitle("Blacklist File Contents")
            .onAppear {
                refreshFiles()
            }
        } else {
            // Fallback on earlier versions
            PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                Haptic.shared.play(.rigid)
                refreshFiles()
            }
            List {
                Section {
                    Text(blacklistContent)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Label("Blacklist", systemImage: "xmark.seal")
                }
                
                Section {
                    Text(bannedAppsContent)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Label("Banned Apps", systemImage: "xmark.app")
                }
                
                Section {
                    Text(cdHashesContent)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Label("CD Hashes", systemImage: "number.square")
                }
                
            }
            .navigationTitle("Blacklist File Contents")
            .onAppear {
                refreshFiles()
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
                            .scaleEffect(1.75)
                            .onAppear {
                                Haptic.shared.play(.light)
                            }
                    } else {
                        Text("")
                    }
                    Spacer()
                }
            }.padding(.top, -50)
        }
    }
    
    func refreshFiles() {
        print("Updating files!")
        blacklistContent = ""
        bannedAppsContent = ""
        cdHashesContent = ""
        blacklistContent = Whitelist.readFile(path: "/private/var/db/MobileIdentityData/Rejections.plist") ?? "ERROR: Could not read from file! Does it even exist?"
        bannedAppsContent = Whitelist.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist") ?? "ERROR: Could not read from file! Does it even exist?"
        cdHashesContent = Whitelist.readFile(path: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist") ?? "ERROR: Could not read from file! Does it even exist?"
        print("Files updated!")
    }
        
}

struct FileContentsView_Previews: PreviewProvider {
    static var previews: some View {
        FileContentsView()
    }
}
