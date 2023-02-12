//
//  BadgeColorChangerView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI
import Photos

struct SpringboardColorChangerView: View {
    @State private var badgeColor = Color.red
    @State private var badgeRadius: CGFloat = 24
    @State private var showingBadgeImagePicker = false
    @State private var badgeImage: UIImage?
    @State private var didChangeBadge: Bool = false
    
    
    @State private var folderColor = Color.gray//.opacity(0.2)
    @State private var folderBlur: Double = 30
    @State private var folderBGColor = Color.gray//.opacity(0.2)
    @State private var folderBGBlur: Double = 30
    
    @State private var dockColor = Color.gray//.opacity(0.2)
    @State private var dockBlur: Double = 30
    
    @State private var notifColor = Color.gray
    @State private var notifBlur: Double = 30
    
    @State private var switcherColor = Color.gray//.opacity(0.2)
    @State private var switcherBlur: Double = 30
    
    
    var body: some View {
        
        GeometryReader { proxy in
            let minSize = min(proxy.size.width, proxy.size.height)
            ZStack(alignment: .center) {
                Image(uiImage: UIImage(named: "wallpaper")!)//WallpaperGetter.homescreen() ?? UIImage(named: "wallpaper")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.5)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                MaterialView(.light)
                    .brightness(-0.4)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 50) {
                        if #unavailable(iOS 16) {
                            // MARK: Badge
                            VStack {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: UIImage(named: "1024")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: minSize / 2, height: minSize / 2)
                                        .cornerRadius(minSize / 8)
                                    ZStack {
                                        if badgeImage == nil {
                                            Rectangle()
                                                .fill(badgeColor)
                                                .frame(width: minSize / 5, height: minSize / 5)
                                                .cornerRadius(minSize * badgeRadius / 240)
                                        } else {
                                            Image(uiImage: badgeImage!)
                                                .resizable()
                                                .frame(width: minSize / 5, height: minSize / 5)
                                        }
                                        Text("1", comment: "Notification Badge Bubble text. (1 notification)")
                                            .foregroundColor(.white)
                                            .font(.system(size: 45))
                                    }
                                    .offset(x: minSize / 12, y:  -minSize / 12)
                                }
                                Text("Cowabunga")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                HStack {
                                    ColorPicker("Set badge color", selection: $badgeColor)
                                        .labelsHidden()
                                        .scaleEffect(1.5)
                                        .padding()
                                    Slider(value: $badgeRadius, in: 0...24)
                                        .frame(width: minSize / 2)
                                }
                                Button(action: {
                                    if badgeImage == nil {
                                        showBadgePicker()
                                    } else {
                                        badgeImage = nil
                                    }
                                }) {
                                    Text(badgeImage == nil ? "Custom image" : "Clear image")
                                        .padding(10)
                                        .background(Color.secondary)
                                        .cornerRadius(8)
                                        .foregroundColor(.init(uiColor14: .systemBackground))
                                }
                                
                                Button("Apply", action: {
                                    applyBadge()
                                })
                                .buttonStyle(TintedButton(color: .blue))
                                .padding(4)
                            }
                            
                            divider
                        }
                        
                        // MARK: Notif Banner
                        VStack {
                            let iconColors: [Color] = [.orange, .blue.opacity(0), .green.opacity(0), .purple.opacity(0)]
                            ZStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: minSize / 15)
                                        .fill(notifColor)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: minSize / 4)
                                        .padding(.horizontal)
                                        .opacity(0.6)
                                }
                                HStack(spacing: 20) {
                                    ForEach(0...3, id: \.self) { i1 in
                                        RoundedRectangle(cornerRadius: minSize / 24)
                                            .fill(iconColors[i1])
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: minSize / 7)
                                    }
                                }
                                .padding(24)
                            }
                            .padding(.bottom, 20)
                            
                            VStack{
                                HStack {
                                    Text("Notif Banner")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    ColorPicker("Set notification banner color", selection: $notifColor)
                                        .labelsHidden()
                                        .scaleEffect(1.5)
                                        .padding(.horizontal, 50)
                                }
                                HStack {
                                    Text("Blur:   \(Int(notifBlur))")
                                        .foregroundColor(.white)
                                        .frame(width: 125)
                                    Spacer()
                                    Slider(value: $notifBlur, in: 0...150, step: 1.0)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            HStack {
                                Button("Apply", action: {
                                    apply(.notif, notifColor, Int(notifBlur))
                                })
                                .buttonStyle(TintedButton(color: .blue))
                                .padding(4)
                                
                                Button(action: {
                                    do {
                                        try SpringboardColorManager.deteleColor(forType: .notif)
                                        UIApplication.shared.alert(title: "Success!", body: "Successfully deleted color files.")
                                    } catch {
                                        UIApplication.shared.alert(title: "Error deleting color files!", body: error.localizedDescription)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(TintedButton(color: .red))
                                .padding(4)
                            }
                        }
                        
                        divider
                        
                        // MARK: Folder
                        VStack {
                            let iconColors: [Color] = [.blue, .orange, .green, .purple, .white, .secondary]
                            ZStack {
                                ZStack {
                                    // Background
                                    RoundedRectangle(cornerRadius: minSize / 32)
                                        .fill(folderBGColor)
                                        .frame(width: minSize/2, height: minSize*0.8)
                                        .opacity(0.3)
                                    
                                    // Folder Itself
                                    RoundedRectangle(cornerRadius: minSize / 24)
                                        .fill(folderColor)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: minSize / 4, height: minSize / 4)
                                        .opacity(0.3)
                                }
                                VStack(spacing: minSize / 50) {
                                    ForEach(0...1, id: \.self) { i1 in
                                        HStack(spacing: minSize / 50) {
                                            ForEach(0...2, id: \.self) { i2 in
                                                RoundedRectangle(cornerRadius: minSize / 60)
                                                    .fill(iconColors[i1 * 3 + i2])
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: minSize / 20, height: minSize / 20)
                                                    .opacity(i1 == 1 && i2 == 2 ? 0 : 1)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.top, minSize*0.31)
                            }
                            .padding(.bottom, 20)
                            
                            VStack{
                                HStack {
                                    Text("Folder")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    ColorPicker("Set folder color", selection: $folderColor)
                                        .labelsHidden()
                                        .scaleEffect(1.5)
                                        .padding(.horizontal, 50)
                                }
                                HStack {
                                    Text("Blur:   \(Int(folderBlur))")
                                        .foregroundColor(.white)
                                        .frame(width: 125)
                                    Spacer()
                                    Slider(value: $folderBlur, in: 0...150, step: 1.0)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            VStack{
                                HStack {
                                    Text("Background")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    ColorPicker("Set expanded folder background color", selection: $folderBGColor)
                                        .labelsHidden()
                                        .scaleEffect(1.5)
                                        .padding(.horizontal, 50)
                                }
                                HStack {
                                    Text("Blur:   \(Int(folderBGBlur))")
                                        .foregroundColor(.white)
                                        .frame(width: 125)
                                    Spacer()
                                    Slider(value: $folderBGBlur, in: 0...150, step: 1.0)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            HStack {
                                Button("Apply", action: {
                                    apply(.folder, folderColor, Int(folderBlur), false)
                                    apply(.libraryFolder, folderColor, Int(folderBlur), false)
                                    apply(.folderBG, folderBGColor, Int(folderBGBlur))
                                })
                                .buttonStyle(TintedButton(color: .blue))
                                .padding(4)
                                
                                Button(action: {
                                    do {
                                        try SpringboardColorManager.deteleColor(forType: .folder)
                                        try SpringboardColorManager.deteleColor(forType: .folderBG)
                                        try SpringboardColorManager.deteleColor(forType: .libraryFolder)
                                        UIApplication.shared.alert(title: "Success!", body: "Successfully deleted color files.")
                                    } catch {
                                        UIApplication.shared.alert(title: "Error deleting color files!", body: error.localizedDescription)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(TintedButton(color: .red))
                                .padding(4)
                            }
                        }
                        
                        divider
                        
                        // MARK: Dock
                        VStack {
                            let iconColors: [Color] = [.blue, .orange, .green, .purple]
                            ZStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: minSize / 15)
                                        .fill(dockColor)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: minSize / 4)
                                        .padding(.horizontal)
                                        .opacity(0.3)
                                }
                                HStack(spacing: 20) {
                                    ForEach(0...3, id: \.self) { i1 in
                                        RoundedRectangle(cornerRadius: minSize / 24)
                                            .fill(iconColors[i1])
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: minSize / 7)
                                    }
                                }
                                .padding(24)
                            }
                            .padding(.bottom, 20)
                            
                            VStack{
                                HStack {
                                    Text("Dock")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    ColorPicker("Set dock color", selection: $dockColor)
                                        .labelsHidden()
                                        .scaleEffect(1.5)
                                        .padding(.horizontal, 50)
                                }
                                HStack {
                                    Text("Blur:   \(Int(dockBlur))")
                                        .foregroundColor(.white)
                                        .frame(width: 125)
                                    Spacer()
                                    Slider(value: $dockBlur, in: 0...150, step: 1.0)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            HStack {
                                Button("Apply", action: {
                                    apply(.dock, dockColor, Int(dockBlur))
                                })
                                .buttonStyle(TintedButton(color: .blue))
                                .padding(4)
                                
                                Button(action: {
                                    do {
                                        try SpringboardColorManager.deteleColor(forType: .dock)
                                        UIApplication.shared.alert(title: "Success!", body: "Successfully deleted color files.")
                                    } catch {
                                        UIApplication.shared.alert(title: "Error deleting color files!", body: error.localizedDescription)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(TintedButton(color: .red))
                                .padding(4)
                            }
                        }
                        
                        divider
                        
                        // MARK: App Switcher Background
                        VStack {
                            let iconColors: [Color] = [.blue, .orange, .green, .purple]
                            ZStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: minSize / 32)
                                        .fill(switcherColor)
                                        .frame(width: minSize/2, height: minSize*0.8)
                                        .opacity(0.3)
                                }
                                HStack(spacing: -90) {
                                    ForEach(0...2, id: \.self) { i1 in
                                        RoundedRectangle(cornerRadius: minSize / 24)
                                            .fill(iconColors[i1])
                                            .frame(width: minSize / 3.5)
                                        //.scaleEffect(1 - (0.05*i1))
                                    }
                                }
                                .padding(24)
                            }
                            .padding(.bottom, 20)
                            
                            VStack{
                                HStack {
                                    Text("App Switcher")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    ColorPicker("Set app switcher color", selection: $switcherColor)
                                        .labelsHidden()
                                        .scaleEffect(1.5)
                                        .padding(.horizontal, 50)
                                }
                                HStack {
                                    Text("Blur:   \(Int(switcherBlur))")
                                        .foregroundColor(.white)
                                        .frame(width: 125)
                                    Spacer()
                                    Slider(value: $switcherBlur, in: 0...150, step: 1.0)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            HStack {
                                Button("Apply", action: {
                                    apply(.switcher, switcherColor, Int(switcherBlur))
                                })
                                .buttonStyle(TintedButton(color: .blue))
                                .padding(4)
                                
                                Button(action: {
                                    do {
                                        try SpringboardColorManager.deteleColor(forType: .switcher)
                                        UIApplication.shared.alert(title: "Success!", body: "Successfully deleted color files.")
                                    } catch {
                                        UIApplication.shared.alert(title: "Error deleting color files!", body: error.localizedDescription)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(TintedButton(color: .red))
                                .padding(4)
                            }
                            .padding(.bottom, 100)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 64)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingBadgeImagePicker) {
            ImagePickerView(image: $badgeImage, didChange: $didChangeBadge)
        }
        
    }
    
    @ViewBuilder
        var divider: some View {
            Divider()
                .overlay(Color.white.opacity(0.25))
                .padding(.horizontal, 32)
        }
    
    func showBadgePicker() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                showingBadgeImagePicker = status == .authorized
            }
        }
    }
    
    
    // MARK: Apply
    func applyBadge() {
        do {
            if badgeImage == nil {
                try BadgeChanger.change(to: UIColor(badgeColor), with: badgeRadius)
            } else {
                try BadgeChanger.change(to: badgeImage!)
            }
            UIApplication.shared.alert(title:  "Success!", body: "Please respring to see changes.")
        } catch {
            UIApplication.shared.alert(body:"An error occured. " + error.localizedDescription)
        }
    }
    func apply(_ sbType: SpringboardColorManager.SpringboardType, _ color: Color, _ blur: Int, _ alert: Bool = true) {
        do {
            try SpringboardColorManager.createColor(forType: sbType, color: CIColor(color: UIColor(color)), blur: blur)
            SpringboardColorManager.applyColor(forType: sbType)
            if alert == true {
                UIApplication.shared.alert(title: "Success!", body: "Please respring to see changes.")
            }
        } catch {
            UIApplication.shared.alert(body:"An error occured. " + error.localizedDescription)
        }
    }
}

struct SpringboardColorChangerView_Previews: PreviewProvider {
    static var previews: some View {
        SpringboardColorChangerView()
    }
}
