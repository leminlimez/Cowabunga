//
//  BadgeColorChangerView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI
import Photos

struct SpringboardColorChangerView: View {
    @StateObject var viewModel = ChangeAppIconViewModel()
    
    @State private var badgeColor = Color.red
    @State private var badgeRadius: CGFloat = 24
    @State private var showingBadgeImagePicker = false
    @State private var badgeImage: UIImage?
    @State private var didChangeBadge: Bool = false
    
    
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
                
                VStack(spacing: 50) {
                    if #unavailable(iOS 16) {
                        // MARK: Badge
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: viewModel.selectedAppIcon.preview)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: minSize / 2, height: minSize / 2)
                                    .cornerRadius(minSize / 10)
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
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 64)
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
}

struct SpringboardColorChangerView_Previews: PreviewProvider {
    static var previews: some View {
        SpringboardColorChangerView()
    }
}
