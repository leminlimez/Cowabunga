//
//  AssetCatalogEditView.swift
//  Cowabunga
//
//  Created by lemin on 3/6/23.
//

import SwiftUI
import AssetCatalogWrapper
import Photos

struct AssetCatalogEditView: View {
    @State var filePath: String
    @State var operation: AssetCatalogObject = AssetCatalogObject(operationName: "Temp", filePath: "/", applyInBackground: false)
    @State var viewingImages: [String: UIImage] = [:]
    @Binding var replacingImages: [String: UIImage]
    
    @State var current: String = ""
    @State private var showingImagePicker: Bool = false
    @State private var changingImage: UIImage? = nil
    @State private var didChange: Bool = false
    
    @State var dragOffset: CGFloat = 0
    @State var animating: Bool = false
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 80, maximum: 80))]
    let animSpeed: Double = 0.2
    
    var body: some View {
        GeometryReader { screenGeometry in
            VStack {
                if viewingImages.count > 0 {
                    if current == "" {
                        ScrollView {
                            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                                ForEach((0...viewingImages.count-1), id: \.self) { c in
                                    Button(action: {
                                        current = getDictKeyByIndex(viewingImages, c)
                                    }) {
                                        getDictValueByIndex(viewingImages, c)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding(5)
                                    }
                                }
                            }
                        }
                    } else {
                        // MARK: Original Image
                        Image(uiImage: viewingImages[current]!)
                            .resizable()
                            .scaledToFit()
                            .offset(CGSize(width: 0, height: dragOffset))
                            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                .onChanged { value in
                                    dragOffset = value.translation.height
                                }
                                .onEnded { value in
//                                    let horizontalAmount = value.translation.width
                                    let verticalAmount = value.translation.height

                                    //if abs(horizontalAmount) < abs(verticalAmount) {
                                        if abs(verticalAmount) > 50 {
                                            current = ""
                                            dragOffset = 0
                                        } else {
                                            animating = true
                                            withAnimation(Animation.linear(duration: animSpeed)) {
                                                dragOffset = 0
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + animSpeed + 0.05, execute: {
                                                animating = false
                                            })
                                        }
                                    //}
                                }).allowsHitTesting(!animating)
                            .frame(maxHeight: screenGeometry.size.height/3)
                        
                        Text("Original")
                            .bold()
                            .foregroundColor(.secondary)
                            .offset(CGSize(width: 0, height: dragOffset))
                        
                        // MARK: Replacing Image
                        if replacingImages[current] != nil {
                            Image(uiImage: replacingImages[current]!)
                                .resizable()
                                .scaledToFit()
                                .offset(CGSize(width: 0, height: dragOffset))
                                .frame(maxHeight: screenGeometry.size.height/3)
                            
                            Text("New")
                                .bold()
                                .foregroundColor(.secondary)
                                .offset(CGSize(width: 0, height: dragOffset))
                        }
                        
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(uiColor14: .secondarySystemFill))
                                .frame(maxWidth: .infinity)
                                .frame(height: screenGeometry.size.height/9)
                            
                            VStack {
                                Text(current)
                                    .bold()
                                    .font(.title3)
                                    .padding(.top, 5)
                                    .padding(.bottom, 3)
                                
                                // MARK: Choosing Image
                                if replacingImages[current] == nil {
                                    Button(action: {
                                        showPicker()
                                    }) {
                                        Text("Choose Image")
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.bottom, 5)
                                } else {
                                    Button(action: {
                                        replacingImages[current] = nil
                                    }) {
                                        Text("Remove Image")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                    }
                } else {
                    Text("No images found!")
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
//        GeometryReader { screenGeometry in
//            VStack {
//
//                // MARK: Old Image
//                ZStack {
//                    // MARK: Previous Image
//                    if current > 0 {
//                        getDictValueByIndex(viewingImages, current - 1)
//                            .resizable()
//                            .scaledToFit()
//                            .offset(CGSize(width: -screenGeometry.size.width + dragOffset, height: 0))
//                    }
//
//                    // MARK: Current Image
//                    if viewingImages.count > 0 {
//                        getDictValueByIndex(viewingImages, current)
//                            .resizable()
//                            .scaledToFit()
//                            .offset(CGSize(width: dragOffset, height: 0))
//                            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
//                                .onChanged { value in
//                                    dragOffset = value.translation.width
//                                }
//                                .onEnded { value in
//                                    let horizontalAmount = value.translation.width
//                                    let verticalAmount = value.translation.height
//
//                                    if abs(horizontalAmount) > abs(verticalAmount) {
//                                        if abs(horizontalAmount) >= screenGeometry.size.width/2 {
//                                            if horizontalAmount > 0 {
//                                                // swipe right
//                                                animating = true
//                                                if current > 0 {
//                                                    withAnimation(Animation.linear(duration: animSpeed)) {
//                                                        dragOffset = screenGeometry.size.width
//                                                    }
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + animSpeed + 0.05, execute: {
//                                                        current -= 1
//                                                        dragOffset = 0
//                                                        animating = false
//                                                    })
//                                                } else {
//                                                    withAnimation(Animation.linear(duration: animSpeed)) {
//                                                        dragOffset = 0
//                                                    }
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + animSpeed + 0.05, execute: {
//                                                        animating = false
//                                                    })
//                                                }
//                                            } else {
//                                                // swipe left
//                                                animating = true
//                                                if current < viewingImages.count - 1 {
//                                                    withAnimation(Animation.linear(duration: animSpeed)) {
//                                                        dragOffset = -screenGeometry.size.width
//                                                    }
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + animSpeed + 0.05, execute: {
//                                                        current += 1
//                                                        dragOffset = 0
//                                                        animating = false
//                                                    })
//                                                } else {
//                                                    withAnimation(Animation.linear(duration: animSpeed)) {
//                                                        dragOffset = 0
//                                                    }
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + animSpeed + 0.05, execute: {
//                                                        animating = false
//                                                    })
//                                                }
//                                            }
//                                        } else {
//                                            animating = true
//                                            withAnimation(Animation.linear(duration: animSpeed)) {
//                                                dragOffset = 0
//                                            }
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + animSpeed + 0.05, execute: {
//                                                animating = false
//                                            })
//                                        }
//                                    }
//                                }).allowsHitTesting(!animating)
//                    }
//
//                    // MARK: Next Image
//                    if current < viewingImages.count-1 {
//                        getDictValueByIndex(viewingImages, current+1)
//                            .resizable()
//                            .scaledToFit()
//                            .offset(CGSize(width: screenGeometry.size.width + dragOffset, height: 0))
//                    }
//                }
//                .frame(maxHeight: screenGeometry.size.height/3)
//
//                Text(viewingImages.count > 0 ? "Original" : "No images found!")
//                    .bold()
//                    .foregroundColor(.secondary)
//
//                // MARK: New Image
//                ZStack {
//                    // MARK: Previous Image
//                    if current > 0 && replacingImages[getDictKeyByIndex(viewingImages, current - 1)] != nil {
//                        Image(uiImage: replacingImages[getDictKeyByIndex(viewingImages, current - 1)]!)
//                            .resizable()
//                            .scaledToFit()
//                            .offset(CGSize(width: -screenGeometry.size.width + dragOffset, height: 0))
//                    }
//
//                    // MARK: Current Image
//                    if viewingImages.count > 0 && replacingImages[getDictKeyByIndex(viewingImages, current)] != nil {
//                        Image(uiImage: replacingImages[getDictKeyByIndex(viewingImages, current)]!)
//                            .resizable()
//                            .scaledToFit()
//                            .offset(CGSize(width: dragOffset, height: 0))
//                    }
//
//                    // MARK: Next Image
//                    if current < viewingImages.count-1 && replacingImages[getDictKeyByIndex(viewingImages, current+1)] != nil {
//                        Image(uiImage: replacingImages[getDictKeyByIndex(viewingImages, current+1)]!)
//                            .resizable()
//                            .scaledToFit()
//                            .offset(CGSize(width: screenGeometry.size.width + dragOffset, height: 0))
//                    }
//                }
//                .frame(maxHeight: screenGeometry.size.height/3)
//
//                if replacingImages[getDictKeyByIndex(viewingImages, current)] != nil {
//                    Text("New")
//                        .bold()
//                        .foregroundColor(.secondary)
//                }
//
//                Spacer()
//                ZStack {
//                    Rectangle()
//                        .foregroundColor(Color(uiColor14: .secondarySystemFill))
//                        .frame(maxWidth: .infinity)
//                        .frame(height: screenGeometry.size.height/9)
//
//                    VStack {
//                        Text(getDictKeyByIndex(viewingImages, current))
//                            .bold()
//                            .font(.title3)
//                            .padding(.top, 5)
//                            .padding(.bottom, 3)
//
//                        // MARK: Choosing Image
//                        if replacingImages[getDictKeyByIndex(viewingImages, current)] == nil {
//                            Button(action: {
//                                showPicker()
//                            }) {
//                                Text("Choose Image")
//                                    .foregroundColor(.blue)
//                            }
//                            .padding(.bottom, 5)
//                        } else {
//                            Button(action: {
//                                replacingImages[getDictKeyByIndex(viewingImages, current)] = nil
//                            }) {
//                                Text("Remove Image")
//                                    .foregroundColor(.red)
//                            }
//                            .padding(.bottom, 5)
//                        }
//                    }
//                }
//            }
            .onAppear {
                if filePath != "" {
                    operation.filePath = filePath
                    if URL(fileURLWithPath: filePath).pathExtension == "car" {
                        viewingImages = operation.getAssets()
                    }
                }
                //replacingImages[getDictKeyByIndex(viewingImages, 0)] = Image("Adobe-Dog")
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(image: $changingImage, didChange: $didChange)
                    .onChange(of: didChange) { new in
                        if new == true && changingImage != nil {
                            replacingImages[current] = changingImage!
                            changingImage = nil
                            didChange = false
                        }
                    }
            }
        }
    }
    
    func getDictValueByIndex(_ dict: [String: UIImage], _ index: Int) -> Image {
        return Image(uiImage: dict.values[dict.index(dict.startIndex, offsetBy: index)])
    }
    
    func getDictKeyByIndex(_ dict: [String: UIImage], _ index: Int) -> String {
        if dict.count > 0 {
            return dict.keys[dict.index(dict.startIndex, offsetBy: index)]
        } else {
            return "None"
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

//struct AssetCatalogEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        AssetCatalogEditView(filePath: "", viewingImages: [
//            "AppIcon": UIImage(imageLiteralResourceName: "AppIcon-preview"),
//            "Adobe Dog": UIImage(imageLiteralResourceName: "Adobe-Dog")
//        ], replacingImages: [:])
//    }
//}
