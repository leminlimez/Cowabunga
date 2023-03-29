//
//  ContentView.swift
//  Cowabunga
//
//  Created by lemin on 1/3/23.
//

import SwiftUI

var inProgress = false
var CardAnimationSpeed = 0.3

struct SpringBoardView: View {
    // lazyvgrid
    private var gridItemLayout = [GridItem(.adaptive(minimum: 150))]
    
    @State var flippedOption: GeneralOption?
    
    // list of options
    @State var tweakOptions: [GeneralOption] = [
        .init(value: getDefaultStr(forKey: "Dock"), key: "Dock", sbType: .dock, title: NSLocalizedString("Dock", comment: "Springboard tool"), imageName: "dock.rectangle", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "HomeBar"), key: "HomeBar", title: NSLocalizedString("Home Bar", comment: "Springboard tool"), imageName: "iphone", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Disabled"]),
        .init(value: getDefaultStr(forKey: "FolderBG"), key: "FolderBG", sbType: .folder, title: NSLocalizedString("Folder Background", comment: "Springboard tool"), imageName: "folder", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "FolderBlur"), key: "FolderBlur", sbType: .folderBG, title: NSLocalizedString("Folder Blur", comment: "Springboard tool"), imageName: "folder.circle", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "CCModuleBG"), key: "CCModuleBG", sbType: .module, title: NSLocalizedString("CC Module Background", comment: "Springboard tool"), shortTitle: "CC Module BG", imageName: "switch.2", fileType: OverwritingFileTypes.cc, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "CCBG"), key: "CCBG", sbType: .moduleBG, title: NSLocalizedString("CC Background Blur", comment: "Springboard tool"), imageName: "switch.2", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "Switcher"), key: "Switcher", sbType: .switcher, title: NSLocalizedString("App Switcher Blur", comment: "Springboard tool"), imageName: "apps.iphone", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Blur", "Disabled"]),
        .init(value: getDefaultStr(forKey: "PodBG"), key: "PodBG", sbType: .libraryFolder, title: NSLocalizedString("Library Pod Background", comment: "Springboard tool"), shortTitle: "Library Pod BG", imageName: "square.stack", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "NotifBG"), key: "NotifBG", sbType: .notif, title: NSLocalizedString("Notification Banner Background", comment: "Springboard tool"), shortTitle: "Notification BG", imageName: "platter.filled.top.iphone", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
        .init(value: getDefaultStr(forKey: "NotifShadow"), key: "NotifShadow", sbType: .notifShadow, title: NSLocalizedString("Notification Banner Shadow", comment: "Springboard tool"), shortTitle: "Notification Shadow", imageName: "platter.filled.top.iphone", fileType: OverwritingFileTypes.springboard, options: ["Visible", "Color", "Disabled"]),
//        .init(value: getDefaultStr(forKey: "ShortcutBanner"), key: "ShortcutBanner", title: NSLocalizedString("Shortcut Notification Banner", comment: "Springboard tool"), imageName: "pencil.slash", fileType: .springboard, options: ["Visible", "Disabled"], minimumOS: 16)
    ]
    
    var body: some View {
        GeometryReader { screenGeometry in
            ZStack {
                Rectangle()
                    .opacity(0)
                    .ignoresSafeArea(edges: .all)
                    .blur(radius: flippedOption == nil ? 0 : 8, opaque: false)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                ScrollView {
                    VStack {
                        Button("Apply") {
                            if flippedOption == nil {
                                applyTweaks()
                            } else {
                                withAnimation(Animation.easeInOut(duration: CardAnimationSpeed)) {
                                    for (i, opt) in tweakOptions.enumerated() {
                                        if opt.title == flippedOption?.title {
                                            tweakOptions[i].animate3d = false
                                            break
                                        }
                                    }
                                    flippedOption = nil
                                }
                            }
                        }
                        .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                        
                        Spacer()
                    }
                    .blur(radius: flippedOption == nil ? 0 : 8, opaque: false)
                    
                    LazyVGrid(columns: gridItemLayout, alignment: .center) {
                        ForEach($tweakOptions) { option in
                            if option.minimumOS.wrappedValue == 16 {
                                // I wish there was a way to do this with variables
                                if #available(iOS 16, *) {
                                    SpringBoardOptionView(option: option, screenGeom: screenGeometry, flippedOption: $flippedOption, otherOptions: $tweakOptions)
                                        .zIndex(option.flipped.wrappedValue ? 2 : 0)
                                        .blur(radius: (flippedOption == nil || flippedOption!.title == option.title.wrappedValue) ? 0 : 8, opaque: false)
                                }
                            } else {
                                SpringBoardOptionView(option: option, screenGeom: screenGeometry, flippedOption: $flippedOption, otherOptions: $tweakOptions)
                                    .zIndex(option.flipped.wrappedValue ? 2 : 0)
                                    .blur(radius: (flippedOption == nil || flippedOption!.title == option.title.wrappedValue) ? 0 : 8, opaque: false)
                                    .environment(\.layoutDirection, .leftToRight)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .coordinateSpace(name: "mainFrame")
            .onAppear {
                for (i, option) in tweakOptions.enumerated() {
                    tweakOptions[i].value = getDefaultStr(forKey: option.key)
                    tweakOptions[i].selectedOption = option.value
                    if option.sbType != nil {
                        if option.value == "Color" {
                            tweakOptions[i].color = SpringboardColorManager.getColor(forType: option.sbType!)
                            tweakOptions[i].blur = SpringboardColorManager.getBlur(forType: option.sbType!)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("SpringBoard Tools")
        .navigationViewStyle(.stack)
    }
    
    func apply(_ sbType: SpringboardColorManager.SpringboardType, _ color: Color, _ blur: Int, save: Bool = true) -> Bool {
        do {
            try SpringboardColorManager.createColor(forType: sbType, color: CIColor(color: UIColor(color)), blur: blur, asTemp: !save)
            SpringboardColorManager.applyColor(forType: sbType, asTemp: !save)
            if !save {
                try SpringboardColorManager.deteleColor(forType: sbType)
            }
            print("Success")
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func applyTweaks() {
        if !inProgress {
            UIApplication.shared.alert(title: NSLocalizedString("Applying Springboard Tweaks...", comment: ""), body: NSLocalizedString("Please wait...", comment: ""), animated: true, withButton: false)
            var failed: Bool = false
            for option in tweakOptions {
                //  apply tweak
                if option.value == "Disabled" {
                    print("Applying tweak \"" + option.title + "\"")
                    var succeeded = false
                    if option.sbType != nil {
                        succeeded = apply(option.sbType!, .gray.opacity(0), 0)
                    } else {
                        succeeded = overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, true)
                    }
                    if succeeded {
                        print("Successfully applied tweak \"" + option.title + "\"")
                    } else {
                        print("Failed to apply tweak \"" + option.title + "\"!!!")
                        failed = true
                    }
                    
                } else if option.value == "Visible" {
                    print("Applying tweak \"" + option.title + "\"")
                    if option.sbType != nil {
                        if option.sbType! == .switcher {
                            let succeeded = apply(option.sbType!, .gray.opacity(1), 20, save: false)
                            if succeeded {
                                print("Successfully applied tweak \"" + option.title + "\"")
                            } else {
                                print("Failed to apply tweak \"" + option.title + "\"!!!")
                            }
                        } else {
                            do {
                                try SpringboardColorManager.revertFiles(forType: option.sbType!)
                                print("Successfully applied tweak \"" + option.title + "\"")
                            } catch {
                                print("Failed to apply tweak \"" + option.title + "\"!!!")
                                print(error.localizedDescription)
                            }
                        }
                    } else {
                        let succeeded = overwriteFile(typeOfFile: option.fileType, fileIdentifier: option.key, false)
                        if succeeded {
                            print("Successfully applied tweak \"" + option.title + "\"")
                        } else {
                            print("Failed to apply tweak \"" + option.title + "\"!!!")
                        }
                    }
                    
                } else if option.value == "Color" || option.value == "Blur" {
                    if option.sbType != nil {
                        print("Applying tweak \"" + option.title + "\"")
                        let succeeded = apply(option.sbType!, option.color, Int(option.blur))
                        if succeeded {
                            print("Successfully applied tweak \"" + option.title + "\"")
                        } else {
                            print("Failed to apply tweak \"" + option.title + "\"!!!")
                            failed = true
                        }
                    } else {
                        print("\(option.title) does not have a springboard type!")
                        failed = true
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIApplication.shared.dismissAlert(animated: true)
                if failed {
                    UIApplication.shared.alert(body: "An error occurred when applying tweaks")
                } else {
                    UIApplication.shared.alert(title: NSLocalizedString("Successfully applied tweaks", comment: "Successfully applied tweaks"), body: NSLocalizedString("Respring to see changes", comment: "Respring to see changes"))
                }
            }
        }
    }
    
    struct GeneralOption: Identifiable {
        var value: String
        var id = UUID()
        var key: String
        var sbType: SpringboardColorManager.SpringboardType?
        var title: String
        var shortTitle: String?
        var imageName: String
        var fileType: OverwritingFileTypes
        var options: [String] = []
        var selectedOption: String = "Visible"
        var flipped: Bool = false
        var animate3d: Bool = false
        
        var minimumOS: Int = 14
        
        var color: Color = Color.gray
        var blur: Double = 30
    }
    
    struct SpringBoardOptionView: View {
        @Binding var option: GeneralOption
        var screenGeom: GeometryProxy
        @Binding var flippedOption: GeneralOption?
        @Binding var otherOptions: [GeneralOption]

        var body: some View {
            return GeometryReader { cardGeometry in
                VStack {
                    Spacer()
                    ZStack {
                        FrontSpringBoardView(option: $option, flippedOption: $flippedOption, otherOptions: $otherOptions).opacity(option.flipped ? 0.0 : 1.0)
                            .frame(width: cardGeometry.size.width, height: cardGeometry.size.height)
                            .scaleEffect(option.animate3d ? (min(screenGeom.size.width*0.95, screenGeom.size.height*0.95)) / cardGeometry.size.width: 1)
                        
                        BackSpringBoardView(option: $option, flippedOption: $flippedOption, screenGeom: screenGeom).opacity(option.flipped ? 1.0 : 0.0)
                            .frame(width: min(screenGeom.size.width, screenGeom.size.height)*0.95, height: min(screenGeom.size.width, screenGeom.size.height)*0.95)
                            .scaleEffect(option.animate3d ? 1 : cardGeometry.size.width / (min(screenGeom.size.width*0.95, screenGeom.size.height*0.95)))
                    }
                    .modifier(FlipEffect(flipped: $option.flipped, angle: option.animate3d ? 180 : 0, axis: (x: 0.25, y: 1)))
                    .offset(x: option.animate3d ? -cardGeometry.frame(in: .named("mainFrame")).origin.x + screenGeom.size.width*0.025: -(screenGeom.size.width*0.95)/2 + cardGeometry.size.width/2, y: option.animate3d ? -cardGeometry.frame(in: .named("mainFrame")).origin.y + (screenGeom.size.height)/8: -screenGeom.size.width/2 + cardGeometry.size.height/2)
                    
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }

    struct FrontSpringBoardView: View {
        @Binding var option: GeneralOption
        @Binding var flippedOption: GeneralOption?
        @Binding var otherOptions: [GeneralOption]
        
        var body: some View {
            return VStack {
                VStack {
                    Image(systemName: option.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                        .opacity(0.5)
                        .padding(.top, 28)
                    
                    Text(option.title)
                        .foregroundColor(.init(uiColor14: .label))
                        .lineLimit(2)
                        .padding(.horizontal)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    Image(systemName: option.selectedOption == "Disabled" ? "x.circle" : "pencil.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(option.selectedOption == "Color" ? .green : .red)
                        .opacity(option.selectedOption == "Visible" ? 0 : 0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical)
                .background(Color(uiColor14: .secondarySystemBackground)
                    .opacity(1)
                )
                .cornerRadius(10)
                .onTapGesture {
                    if flippedOption == nil {
                        withAnimation(Animation.easeInOut(duration: CardAnimationSpeed)) {
                            flippedOption = option
                            option.animate3d.toggle()
                        }
                    } else {
                        withAnimation(Animation.easeInOut(duration: CardAnimationSpeed)) {
                            for (i, opt) in otherOptions.enumerated() {
                                if opt.title == flippedOption?.title {
                                    otherOptions[i].animate3d = false
                                    break
                                }
                            }
                            flippedOption = nil
                        }
                    }
                }
            }
        }
    }
    
    struct BackSpringBoardView: View {
        @Binding var option: GeneralOption
        @Binding var flippedOption: GeneralOption?
        var screenGeom: GeometryProxy
        
        var body: some View {
            return VStack (alignment: .center) {
                HStack {
                    Text(option.shortTitle ?? option.title)
                        .font(.title)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    Spacer()
                }
                
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(uiColor14: .secondarySystemFill))
                        .cornerRadius(8)
                        .frame(width: screenGeom.size.width - 25 - (10 * CGFloat(option.options.count)), height: screenGeom.size.width*0.075)
                    HStack {
                        ForEach(0..<option.options.count) { ind in
                            Button(action: {
                                option.selectedOption = option.options[ind]
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color(uiColor14: .systemBackground).opacity(option.selectedOption == option.options[ind] ? 1 : 0))
                                    Text(option.options[ind])
                                        .font(.system(size: 13))
                                        .lineLimit(1)
                                }
                                .frame(width: (screenGeom.size.width/CGFloat(option.options.count)) - (10 * CGFloat(option.options.count)), height: screenGeom.size.width*0.075)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                .pickerStyle(.segmented)
                Spacer()
                
                // MARK: Visible Text
                if option.selectedOption == "Visible" {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 40))
                    
                // MARK: Color and Blur selector
                } else if option.selectedOption == "Color" || option.selectedOption == "Blur" {
                    VStack{
                        if option.selectedOption == "Color" {
                            HStack {
                                Text("Color:")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 25)
                                Spacer()
                                ColorPicker("Set notification banner color", selection: $option.color)
                                    .labelsHidden()
                                    .scaleEffect(1.5)
                                    .padding(.horizontal, 50)
                            }
                        }
                        HStack {
                            Text("Blur:   \(Int(option.blur))")
                                .frame(width: 125)
                            Spacer()
                            Slider(value: $option.blur, in: 0...150, step: 1.0)
                                .padding(.horizontal)
                        }
                    }
                    
                // MARK: Disabled Text
                } else if option.selectedOption == "Disabled" {
                    Image(systemName: "x.circle")
                        .foregroundColor(.red)
                        .font(.system(size: 40))
                }
                
                Spacer()
                
                Button(action: {
                    // save
                    UserDefaults.standard.set(option.selectedOption, forKey: option.key)
                    option.value = option.selectedOption
                    if option.selectedOption == "Color" || option.selectedOption == "Blur" {
                        do {
                            try SpringboardColorManager.createColor(forType: option.sbType!, color: CIColor(color: UIColor(option.color)), blur: Int(option.blur), asTemp: false)
                            print("Success")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    // close menu
                    if flippedOption!.title == option.title {
                        withAnimation(Animation.easeInOut(duration: CardAnimationSpeed)) {
                            flippedOption = nil
                            option.animate3d.toggle()
                        }
                    }
                }) {
                    Text("Save")
                }
                .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                .padding(25)
            }
            .background(Color(uiColor14: .secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct SpringBoardView_Previews: PreviewProvider {
    static var previews: some View {
        SpringBoardView()
    }
}
