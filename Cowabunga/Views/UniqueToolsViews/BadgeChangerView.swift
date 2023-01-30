//
//  BadgeColorChangerView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI
import Photos

struct BadgeChangerView: View {
    @State private var color = Color.red
    @State private var radius: CGFloat = 24
    @State private var showingImagePicker = false
    @State private var image: UIImage?
    @State private var didChange: Bool = false
    
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
                VStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: UIImage(named: "1024")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: minSize / 2, height: minSize / 2)
                            .cornerRadius(minSize / 8)
                        ZStack {
                            if image == nil {
                                Rectangle()
                                    .fill(color)
                                    .frame(width: minSize / 5, height: minSize / 5)
                                    .cornerRadius(minSize * radius / 240)
                            } else {
                                Image(uiImage: image!)
                                    .resizable()
                                    .frame(width: minSize / 5, height: minSize / 5)
                            }
                            Text("1")
                                .foregroundColor(.white)
                                .font(.system(size: 45))
                        }
                        .offset(x: minSize / 12, y:  -minSize / 12)
                    }
                    Text("TrollTools")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    HStack {
                        ColorPicker("Set badge color", selection: $color)
                            .labelsHidden()
                            .scaleEffect(1.5)
                            .padding()
                        Slider(value: $radius, in: 0...24)
                            .frame(width: minSize / 2)
                    }
                    Button(action: {
                        if image == nil {
                            showPicker()
                        } else {
                            image = nil
                        }
                    }) {
                        Text(image == nil ? "Custom image" : "Clear image")
                            .padding(10)
                            .background(Color.secondary)
                            .cornerRadius(8)
                            .foregroundColor(.init(uiColor14: .systemBackground))
                            .padding(.top, 24)
                    }
                    Button("Apply", action: {
                        do {
                            if image == nil {
                                try BadgeChanger.change(to: UIColor(color), with: radius)
                            } else {
                                try BadgeChanger.change(to: image!)
                            }
                            UIApplication.shared.alert(title: "Success!", body: "Please respring to see changes.")
                        } catch {
                            UIApplication.shared.alert(body:"An error occured. " + error.localizedDescription)
                        }
                    })
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: $image, didChange: $didChange)
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

struct BadgeColorChangerView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeChangerView()
    }
}
