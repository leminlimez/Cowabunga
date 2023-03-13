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
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(value: getDefaultBool(forKey: "DockHidden"), key: "DockHidden", title: NSLocalizedString("Hide Dock", comment: "Springboard tool"), imageName: "dock.rectangle", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "HomeBarHidden"), key: "HomeBarHidden", title: NSLocalizedString("Hide Home Bar", comment: "Springboard tool"), imageName: "iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "FolderBGHidden"), key: "FolderBGHidden", title: NSLocalizedString("Disable Folder Background", comment: "Springboard tool"), imageName: "folder", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "FolderBlurDisabled"), key: "FolderBlurDisabled", title: NSLocalizedString("Disable Folder Blur", comment: "Springboard tool"), imageName: "folder.circle", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "SwitcherBlurDisabled"), key: "SwitcherBlurDisabled", title: NSLocalizedString("Disable App Switcher Blur", comment: "Springboard tool"), imageName: "apps.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "CCModuleBackgroundDisabled"), key: "CCModuleBackgroundDisabled", title: NSLocalizedString("Disable CC Module Background", comment: "Springboard tool"), imageName: "switch.2", fileType: OverwritingFileTypes.cc),
        .init(value: getDefaultBool(forKey: "PodBackgroundDisabled"), key: "PodBackgroundDisabled", title: NSLocalizedString("Disable Library Pods Background", comment: "Springboard tool"), imageName: "square.stack", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "NotifBackgroundDisabled"), key: "NotifBackgroundDisabled", title: NSLocalizedString("Hide Notification Banner Background", comment: "Springboard tool"), imageName: "platter.filled.top.iphone", fileType: OverwritingFileTypes.springboard)
    ]
    
    var body: some View {
        VStack {
            ScrollView {
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
                                    .lineLimit(2)
                                    .padding(.horizontal)
                                    .minimumScaleFactor(0.5)
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
                    Button("Apply") {
                        applyTweaks()
                    }
                    .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .padding()
        .navigationTitle("SpringBoard Tools")
        .navigationViewStyle(.stack)
    }
    
    func applyTweaks() {
        if !inProgress {
            var failed: Bool = false
            for option in tweakOptions {
                //  apply tweak
                print("Applying tweak \"" + option.title + "\"")
                let succeeded = overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, option.value)
                if succeeded {
                    print("Successfully applied tweak \"" + option.title + "\"")
                } else {
                    print("Failed to apply tweak \"" + option.title + "\"!!!")
                    failed = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if failed {
                    UIApplication.shared.alert(body: "An error occurred when applying tweaks")
                } else {
                    UIApplication.shared.alert(title: NSLocalizedString("Successfully applied tweaks", comment: "Successfully applied tweaks"), body: NSLocalizedString("Respring to see changes", comment: "Respring to see changes"))
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
