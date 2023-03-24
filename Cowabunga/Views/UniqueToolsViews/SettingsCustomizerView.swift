//
//  SettingsCustomizerView.swift
//  Cowabunga
//
//  Created by lemin on 3/5/23.
//

import SwiftUI
import Photos

struct SettingsOption: Identifiable {
    var id = UUID()
    var title: String
    var icon: Image
    var iconColor: Color
    var isToggle: Bool = false
    var value: String = ""
}

struct SettingsCustomizerView: View {
    @State var settingsOptions: [SettingsOption] = [
        .init(title: "Airplane Mode", icon: Image(systemName: "airplane"), iconColor: .orange, isToggle: true),
        .init(title: "Wi-Fi", icon: Image(systemName: "wifi"), iconColor: .blue, value: "Not Connected"),
        .init(title: "Bluetooth", icon: Image("logo.bluetooth"), iconColor: .blue, value: "On"),
        .init(title: "Cellular", icon: Image(systemName: "antenna.radiowaves.left.and.right"), iconColor: .green),
        .init(title: "Personal Hotspot", icon: Image(systemName: "personalhotspot"), iconColor: .green)
    ]
    
    @State private var showingImagePicker = false
    @State private var img: UIImage? = SettingsCustomizerManager.getImage()
    @State private var didChange: Bool = false
    @State private var imageScale: Double = UserDefaults.standard.double(forKey: "SETTINGS_ImageScale")
    
    @State private var removesIcons: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_RemoveIcons")
    @State private var removesLabels: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_RemoveLabels")
    @State private var removesPreviews: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_RemovePreviews")
    @State private var useSettingsFootnote: Bool = UserDefaults.standard.bool(forKey: "SETTINGS_UsesFootnote")
    @State private var settingsFootnote: String = UserDefaults.standard.string(forKey: "SETTINGS_Footnote") ?? ""
    
    @State private var funnyToggle: Bool = false
    
    var body: some View {
        GeometryReader { screenGeometry in
            VStack {
                List {
                    Section {
                        // remove icons toggle
                        Toggle(isOn: $removesIcons) {
                            Text("Remove Icons")
                        }.onChange(of: removesIcons) { new in
                            UserDefaults.standard.set(new, forKey: "SETTINGS_RemoveIcons")
                        }
                        // remove labels toggle
                        Toggle(isOn: $removesLabels) {
                            Text("Remove Labels")
                        }.onChange(of: removesLabels) { new in
                            UserDefaults.standard.set(new, forKey: "SETTINGS_RemoveLabels")
                        }
                        // remove previews toggle
                        Toggle(isOn: $removesPreviews) {
                            Text("Remove Previews")
                        }.onChange(of: removesPreviews) { new in
                            UserDefaults.standard.set(new, forKey: "SETTINGS_RemovePreviews")
                        }
                        // uses footnote toggle
                        Toggle(isOn: $useSettingsFootnote) {
                            Text("Use Settings Footnote")
                        }.onChange(of: useSettingsFootnote) { new in
                            UserDefaults.standard.set(new, forKey: "SETTINGS_UsesFootnote")
                        }
                        // footnote textbox
                        if useSettingsFootnote {
                            HStack {
                                Text("Footnote:")
                                Spacer()
                                if #available(iOS 15.0, *) {
                                    TextField("Footnote", text: $settingsFootnote)
                                        .multilineTextAlignment(.trailing)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            UserDefaults.standard.set(settingsFootnote, forKey: "SETTINGS_Footnote")
                                        }
                                } else {
                                    // Fallback on earlier versions
                                    TextField("Footnote", text: $settingsFootnote)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        // choose image
                        HStack {
                            Text("Image:")
                            Spacer()
                            if img == nil {
                                Button(action: {
                                    showingImagePicker.toggle()
                                }) {
                                    Text("Select Image")
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Button(action: {
                                    do {
                                        try SettingsCustomizerManager.removeImage()
                                        img = nil
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }) {
                                    Text("Remove Image")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        // image scale
                        if img != nil {
                            HStack {
                                Text("Scale:   \(Int(imageScale))%")
                                Spacer()
                                Slider(value: $imageScale, in: 5...100, step: 1.0)
                                    .frame(width: 200)
                                    .onChange(of: imageScale) { _ in
                                        UserDefaults.standard.set(imageScale, forKey: "SETTINGS_ImageScale")
                                    }
                            }
                        }
                        
                        // apply button
                        Button("Apply") {
                            UserDefaults.standard.set(settingsFootnote, forKey: "SETTINGS_Footnote")
                            // apply
                            do {
                                try SettingsCustomizerManager.apply()
                                UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The settings properties were successfully changed!", comment: ""))
                            } catch {
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        }
                        .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                    } header: {
                        Text("Preferences")
                    }
                    
                    // MARK: Preview
                    Section {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(uiColor14: .secondarySystemBackground))
                                .cornerRadius(15)
                            VStack {
                                // MARK: Title
                                HStack {
                                    Text("Settings")
                                        .font(.title)
                                        .padding(.horizontal, 15)
                                        .padding(.top, 10)
                                    Spacer()
                                }
                                
                                // MARK: Apple ID Thing
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color(uiColor14: .systemBackground))
                                        .cornerRadius(8)
                                    VStack {
                                        // MARK: Image
                                        if img != nil {
                                            HStack {
                                                Image(uiImage: img!)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: (screenGeometry.size.width - 75) * (imageScale/100))
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                        }
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(Color(uiColor14: .systemFill))
                                                Text("YN")
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.leading, 5)
                                            .padding(.vertical, 5)
                                            VStack (alignment: .leading) {
                                                Text("Your Name")
                                                    .padding(.leading, 3)
                                                    .padding(.bottom, 1)
                                                Text("Apple ID, iCloud, Media & Purchases")
                                                    .font(.caption2)
                                                    .padding(.leading, 3)
                                                    .opacity(removesLabels ? 0 : 1)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(Color(uiColor14: .systemFill))
                                                .padding(.trailing, 5)
                                        }
                                    }
                                }
                                .padding(.horizontal, 15)
                                .padding(.bottom, 15)
                                
                                // MARK: Custom Footer Text
                                if useSettingsFootnote {
                                    Text(settingsFootnote == "" ? "Footnote" : settingsFootnote)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 10)
                                }
                                
                                // MARK: Other Options
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color(uiColor14: .systemBackground))
                                        .cornerRadius(8)
                                    VStack {
                                        ForEach(settingsOptions) { option in
                                            HStack {
                                                ZStack {
                                                    Rectangle()
                                                        .foregroundColor(option.iconColor)
                                                        .cornerRadius(5)
                                                        .frame(width: 25, height: 25)
                                                        .padding(.horizontal, 5)
                                                    option.icon
                                                        .foregroundColor(.white)
                                                        .font(.footnote)
                                                }
                                                .opacity(removesIcons ? 0 : 1)
                                                Text(option.title)
                                                    .font(.footnote)
                                                    .padding(.leading, removesIcons ? 15 : 0)
                                                    .opacity(removesLabels ? 0 : 1)
                                                Spacer()
                                                if option.isToggle {
                                                    Toggle(isOn: $funnyToggle) {
                                                        
                                                    }
                                                    .padding(.horizontal)
                                                } else {
                                                    if option.value != "" && !removesPreviews {
                                                        Text(option.value)
                                                            .font(.footnote)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(Color(uiColor14: .systemFill))
                                                        .padding(.trailing, 5)
                                                }
                                            }
                                            Divider()
                                                .overlay(Color.white.opacity(0.25))
                                        }
                                    }
                                }
                                .padding(.horizontal, 15)
                                .padding(.bottom, 15)
                            }
                        }
                        .padding(.vertical, 20)
                    } header: {
                        Text("Preview")
                    }
                }
            }
        }
        .onAppear {
            img = SettingsCustomizerManager.getImage()
            
            removesIcons = UserDefaults.standard.bool(forKey: "SETTINGS_RemoveIcons")
            removesLabels = UserDefaults.standard.bool(forKey: "SETTINGS_RemoveLabels")
            removesPreviews = UserDefaults.standard.bool(forKey: "SETTINGS_RemovePreviews")
            useSettingsFootnote = UserDefaults.standard.bool(forKey: "SETTINGS_UsesFootnote")
            settingsFootnote = UserDefaults.standard.string(forKey: "SETTINGS_Footnote") ?? ""
            imageScale = UserDefaults.standard.double(forKey: "SETTINGS_ImageScale")
            if imageScale < 5 || imageScale > 100 {
                imageScale = 100
                UserDefaults.standard.set(Double(100), forKey: "SETTINGS_ImageScale")
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: $img, didChange: $didChange)
        }
        .onChange(of: img) { new in
            // set the new image
            if new != nil {
                do {
                    try SettingsCustomizerManager.saveImage(new!)
                } catch {
                    print(error.localizedDescription)
                    img = nil
                }
            }
        }
    }
    
    func showPicker() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                showingImagePicker = status == .authorized
            }
        }
    }
}

struct SettingsCustomizerView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCustomizerView()
    }
}
