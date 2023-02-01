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
    
    
    @State private var folderColor = Color.gray
    
    
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
                    VStack(spacing: 100) {
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
                                    Text("1")
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
                        }
                        .padding(.top, 64)
                        
                        // MARK: Folder
                        VStack {
                            let iconColors: [Color] = [.blue, .orange, .green, .purple, .white, .secondary]
                            ZStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: minSize / 8)
                                        .fill(folderColor.opacity(0.5))
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: minSize / 2, height: minSize / 2)
                                }
                                VStack(spacing: 12) {
                                    ForEach(0...1, id: \.self) { i1 in
                                        HStack(spacing: 12) {
                                            ForEach(0...2, id: \.self) { i2 in
                                                RoundedRectangle(cornerRadius: minSize / 24)
                                                    .fill(iconColors[i1 * 3 + i2])
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: minSize / 9, height: minSize / 9)
                                                    .opacity(i1 == 1 && i2 == 2 ? 0 : 1)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(24)
                            }
                            
                            HStack {
                                Text("Folder")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                ColorPicker("Set badge color", selection: $folderColor)
                                    .labelsHidden()
                                    .scaleEffect(1.5)
                                    .padding()
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .frame(maxWidth: .infinity)
                }
                VStack {
                    Spacer()
                    
                    Button("Apply", action: {
                        do {
                            if badgeImage == nil {
                                try BadgeChanger.change(to: UIColor(badgeColor), with: badgeRadius)
                            } else {
                                try BadgeChanger.change(to: badgeImage!)
                            }
                            UIApplication.shared.alert(title: "Success!", body: "Please respring to see changes.")
                        } catch {
                            UIApplication.shared.alert(body:"An error occured. " + error.localizedDescription)
                        }
                    })
                    .buttonStyle(FullwidthTintedButton(color: .blue))
                    .padding(.top, 24)
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingBadgeImagePicker) {
            ImagePickerView(image: $badgeImage, didChange: $didChangeBadge)
        }
        
    }
    
    func showBadgePicker() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                showingBadgeImagePicker = status == .authorized
            }
        }
    }
}

struct SpringboardColorChangerView_Previews: PreviewProvider {
    static var previews: some View {
        SpringboardColorChangerView()
    }
}
