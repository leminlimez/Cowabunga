//
//  ContentView.swift
//  DockHider
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false

struct SpringBoardView: View {
    struct GeneralOption: Identifiable {
        var value: Bool
        var id = UUID()
        var key: String
        var title: String
        var imageName: String
        var fileType: OverwritingFileTypes
    }
    
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(value: getDefaultBool(forKey: "DockHidden"), key: "DockHidden", title: "Hide Dock", imageName: "platter.filled.bottom.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "HomeBarHidden"), key: "HomeBarHidden", title: "Hide Home Bar", imageName: "iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "FolderBGHidden"), key: "FolderBGHidden", title: "Hide Folder Background", imageName: "folder", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "FolderBlurDisabled"), key: "FolderBlurDisabled", title: "Disable Folder Blur", imageName: "folder.circle.fill", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "SwitcherBlurDisabled"), key: "SwitcherBlurDisabled", title: "Disable App Switcher Blur", imageName: "apps.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "ShortcutBannerDisabled"), key: "ShortcutBannerDisabled", title: "Disable Shortcut Banner", imageName: "platter.filled.top.iphone", fileType: OverwritingFileTypes.springboard),
        .init(value: getDefaultBool(forKey: "AirPowerEnabled"), key: "AirPowerEnabled", title: "Enable AirPower Charging Sound", imageName: "speaker.wave.2.fill", fileType: OverwritingFileTypes.audio),
    ]
    
    @State private var applyText = " "
    
    var body: some View {
        VStack {
            // title
            Text("Cowabunga")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            Text("SpringBoard Tools")
                .font(.title2)
                .padding(.bottom, 10)
            Text(applyText)
                .padding(.bottom, 15)
            
            ForEach($tweakOptions) { option in
                HStack {
                    Image(systemName: option.imageName.wrappedValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                    
                    Toggle(isOn: option.value) {
                        Text(option.title.wrappedValue)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.leading, 10)
                }
            }
            
            Button("Apply and Respring", action: {
                applyTweaks(respringWhenFinished: true)
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
            
            Button("Apply without Respringing", action: {
                applyTweaks(respringWhenFinished: false)
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.white)
            
            Button("Respring", action: {
                respring()
            })
            .padding(10)
            .background(Color.red)
            .cornerRadius(8)
            .foregroundColor(.white)
        }
        .padding()
    }
    
    func applyTweaks(respringWhenFinished: Bool) {
        if !inProgress {
            applyText = "Applying tweaks..."
            //ForEach(tweakOptions) { option in
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
                        }
                    }
                }
            }
            
            if respringWhenFinished {
                // respring and apply changes
                applyText = "Respringing..."
                print("Respringing...")
                respring()
            } else {
                applyText = "Tweaks applied"
                print("Tweaks applied")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    if applyText == "Tweaks applied" {
                        applyText = " "
                    }
                }
            }
        }
    }
}

struct SpringBoardView_Previews: PreviewProvider {
    static var previews: some View {
        SpringBoardView()
    }
}
