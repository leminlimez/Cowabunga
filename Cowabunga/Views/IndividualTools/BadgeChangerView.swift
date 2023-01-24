//
//  BadgeColorChangerView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI

struct BadgeChangerView: View {
    @State private var color = Color.red
    @State private var radius: CGFloat = 24
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
                            Rectangle()
                                .fill(color)
                                .frame(width: minSize / 5, height: minSize / 5)
                                .cornerRadius(minSize * radius / 240)
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
                    Button("Apply and respring", action: {
                        do {
                            try BadgeChanger.change(to: UIColor(color), with: radius)
                            respring()
                        } catch {
                            UIApplication.shared.alert(body: "An error occured. " + error.localizedDescription)
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
    }
}

struct BadgeColorChangerView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeChangerView()
    }
}
