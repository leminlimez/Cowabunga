//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false

struct SpringBoardView: View {
    // lazyvgrid
    private var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(value: getDefaultBool(forKey: "DockHidden"), key: "DockHidden", title: "Hide Dock", imageName: "platter.filled.bottom.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "HomeBarHidden"), key: "HomeBarHidden", title: "Hide Home Bar", imageName: "iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "FolderBGHidden"), key: "FolderBGHidden", title: "Hide Folder Background", imageName: "folder", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "RegionRestrictionsRemoved"), key: "RegionRestrictionsRemoved", title: "Remove Region Restrictions", imageName: "globe", fileType: OverwritingFileTypes.region),
        .init(value: getDefaultBool(forKey: "SwitcherBlurDisabled"), key: "SwitcherBlurDisabled", title: "Disable App Switcher Blur", imageName: "apps.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "ShortcutBannerDisabled"), key: "ShortcutBannerDisabled", title: "Disable Shortcut Banner", imageName: "platter.filled.top.iphone", fileType: OverwritingFileTypes.plist),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach($tweakOptions) { option in
                        Button(action: {
                            option.wrappedValue.value.toggle()
                        }) {
                            VStack {
                                Image(systemName: option.wrappedValue.value ? "checkmark.circle" : option.imageName.wrappedValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.blue)
                                    .opacity(option.wrappedValue.value ? 1 : 0.5)
                                
                                Text(option.title.wrappedValue)
                                    .foregroundColor(.init(uiColor14: .label))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical)
                            .background(Color(uiColor14: option.wrappedValue.value ? .init(hue: 0.6, saturation: 1, brightness: 1, alpha: 0.15) : .secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                VStack {
                    if #available(iOS 15.0, *) {
                        Button("Apply", action: {
                            applyTweaks()
                        })
                        .padding(5)
                        .buttonStyle(.bordered)
                        .tint(.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.accentColor)
                    } else {
                        // Fallback on earlier versions
                        Button("Apply", action: {
                            applyTweaks()
                        })
                        .padding(10)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    }
                    
                    if #available(iOS 15.0, *) {
                        Button("Respring", action: {
                            respring()
                        })
                        .padding(5)
                        .tint(.red)
                        .buttonStyle(.bordered)
                        .cornerRadius(8)
                        .foregroundColor(.red)
                    } else {
                        // Fallback on earlier versions
                        Button("Respring", action: {
                            respring()
                        })
                        .padding(10)
                        .cornerRadius(8)
                        .background(Color.red)
                        .foregroundColor(.white)
                    }
                }
                .padding(.vertical)
            }
            .padding()
            .navigationTitle("SpringBoard Tools")
        }
    }
    
    func applyTweaks() {
        if !inProgress {
            var failed: Bool = false
            for option in tweakOptions {
                // set the user defaults
                setDefaultBoolean(forKey: option.key, value: option.value)
                
                //  apply tweak
                if option.value == true {
                    print("Applying tweak \"" + option.title + "\"")
                    overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, option.value) { succeeded in
                        if succeeded {
                            print("Successfully applied tweak \"" + option.title + "\"")
                        } else {
                            print("Failed to apply tweak \"" + option.title + "\"!!!")
                            failed = true
                        }
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if failed {
                    UIApplication.shared.alert(body: "An error occurred when applying tweaks")
                } else {
                    UIApplication.shared.alert(title: "Successfully applied tweaks!", body: "Respring to see changes.")
                }
            }
        }
    }
    
    struct GeneralOption: Identifiable {
        var value: Bool
        var id = UUID()
        var key: String
        var title: String
        var imageName: String
        var fileType: OverwritingFileTypes
    }
}

struct SpringBoardView_Previews: PreviewProvider {
    static var previews: some View {
        SpringBoardView()
    }
}
