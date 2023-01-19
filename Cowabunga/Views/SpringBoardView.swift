//
//  ContentView.swift
//  Cowabunga
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
        .init(value: getDefaultBool(forKey: "DockHidden"), key: "DockHidden", title: "Hide Dock", imageName: "dock.rectangle", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "HomeBarHidden"), key: "HomeBarHidden", title: "Hide Home Bar", imageName: "iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "FolderBGHidden"), key: "FolderBGHidden", title: "Disable Folder Background", imageName: "folder", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "RegionRestrictionsRemoved"), key: "RegionRestrictionsRemoved", title: "Remove Region Restrictions", imageName: "globe", fileType: OverwritingFileTypes.region),
        .init(value: getDefaultBool(forKey: "SwitcherBlurDisabled"), key: "SwitcherBlurDisabled", title: "Disable Switcher Blur", imageName: "apps.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "ShortcutBannerDisabled"), key: "ShortcutBannerDisabled", title: " Disable Shortcut Banner ", imageName: "pencil.slash", fileType: OverwritingFileTypes.plist),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Spacer()
                Spacer()
                LazyVGrid(columns: gridItemLayout) {
                    ForEach($tweakOptions) { option in
                        Button(action: {
                            option.wrappedValue.value.toggle()
                            
                            // set the user defaults
                            setDefaultBoolean(forKey: option.key.wrappedValue, value: option.value.wrappedValue)
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
                            .background(Color(uiColor14: option.wrappedValue.value ? .init(red: 0, green: 0.47, blue: 1, alpha: 1) : .secondarySystemBackground)
                                .opacity(option.wrappedValue.value ? 0.15 : 1)
                            )
                            .cornerRadius(10)
                        }
                    }
                }
                VStack {
                    if #available(iOS 15.0, *) {
                        Button("Apply", action: {
                            applyTweaks()
                        })
                        .padding(8)
                        .buttonStyle(.bordered)
                        .tint(.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        
                        /*Button("Respring", action: {
                            respring()
                        })
                        .padding(8)
                        .tint(.red)
                        .buttonStyle(.bordered)
                        .cornerRadius(8)
                        .foregroundColor(.red)
                        .frame(maxWidth: 200)*/
                    } else {
                        // for ios 14 nerds still out there
                        
                        Button("Apply", action: {
                            applyTweaks()
                        })
                        .padding(10)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                        /*Button("Respring", action: {
                            respring()
                        })
                        .padding(10)
                        .cornerRadius(8)
                        .background(Color.red)
                        .foregroundColor(.white)*/
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            .padding()
            .navigationTitle("SpringBoard Tools")
        }
        .navigationViewStyle(.stack)
    }
    
    func applyTweaks() {
        if !inProgress {
            var failed: Bool = false
            for option in tweakOptions {
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
