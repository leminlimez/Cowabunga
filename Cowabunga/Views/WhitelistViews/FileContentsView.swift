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
    
    @State var eggCount = 0
    
    let wisdom = ["There is no monster more dangerous than a lack of compassion.",
                  "It's remarkable what one can do, when one is forced to.",
                  "The path that leads to what we truly desire is long and difficult, but only by following that path do we achieve our goal.",
                  "A wise person embraces as many new experiences as possible. The wise person also recognizes that some experiences are less embraceable than others.",
                  "There are times when right overrules rules, my son.",
                  "I do not wish to fight. But cast a stone into the lake, and the ripples will return to you.",
    "If you look for happiness outside of yourself, you'll never find it. Happiness exists only within you.",
                  "Pride in one's work is an excellent quality, but it most not be carried to excess.",
                  "Wisdom can appear in many places.",
                  "I see you have already forgotten your lesson. There is room in this world for all different types of personalities. Some light-hearted, some serious. Think how boring it would be if all of us were identical.",
                  "Possess the right thinking. Only then can one receive the gifts of strength, knowledge, and peace.",
                  "Anger clouds the mind. Turned inward, it is an unconquerable enemy.",
                  "You are unique among your brothers, for you choose to face this enemy alone. But as you face it, do not forget them, and do not forget me. I am here, my son.",
                  "Tonight you have learned the final and greatest truth of the Ninja: that ultimate mastering comes not from the body, but from the mind. Together, there is nothing your four minds cannot accomplish.",
                  "Some say that the path from inner turmoil begins with a friendly ear.  My ear is open if you care to use it.",
                  "Running into battle without knowledge or preparation is foolish. Sometimes it is best to sit still. The answers will come.",
    "Sometimes you must follow your heart even if others tell you not to.",
                  "A creative mind must be balanced by a disciplined body. We must learn stillness and alertness. For they are the only defense against the unexpected.",
                  "Darkness gives the ninja power, while light reveals the ninja's presence.",
                  "A wise ninja does not seek out an enemy who he does not fully understand."]
    
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
                Section{} header: {
                    Text("🍕")
                        .onTapGesture{paintedEggs()}
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
    func paintedEggs() {
        eggCount += 1
        if eggCount == 5 {
            Haptic.shared.notify(.success)
            UIApplication.shared.alert(title:"Wisdom of the Day", body: wisdom.randomElement()!)
            eggCount = 0
        }
    }
        
}

struct FileContentsView_Previews: PreviewProvider {
    static var previews: some View {
        FileContentsView()
    }
}
