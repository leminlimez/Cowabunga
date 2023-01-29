//
//  PasscodeEditorView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI
import Photos

struct PasscodeEditorView: View {
    @State private var ipadView: Bool = false
    
    @State private var showingImagePicker = false
    @State private var faces: [UIImage?] = [UIImage?](repeating: nil, count: 10)
    @State private var changedFaces: [Bool] = [Bool](repeating: false, count: 10)
    @State private var canChange = false // needed to make sure it does not reset the size on startup
    @State private var changingFaceN = 0
    @State private var isBig = false
    @State private var customSize: [String] = [String(KeySize.small.rawValue), String(KeySize.small.rawValue)]
    @State private var currentSize: Int = 0
    //@State private var sizeButtonState = KeySizeState.small
    @State private var isImporting = false
    @State private var isExporting = false
    
    @State private var sizeLimit: [Int] = [PasscodeSizeLimit.min.rawValue, PasscodeSizeLimit.max.rawValue] // the limits of the custom size (max, min)
    
    let fm = FileManager.default
    
    var body: some View {
        GeometryReader { proxy in
            //let minSize = min(proxy.size.width, proxy.size.height)
            ZStack(alignment: .center) {
                Image(uiImage: UIImage(named: "wallpaper")!)//WallpaperGetter.lockscreen() ?? UIImage(named: "wallpaper")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.5)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .offset(y: UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
                MaterialView(.light)
                    .brightness(-0.4)
                    .ignoresSafeArea()
                
                //                Rectangle()
                //                    .background(Material.ultraThinMaterial)
                //                    .ignoresSafeArea()
                //                    .preferredColorScheme(.dark)
                VStack {Text("Passcode Face Editor")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(1)
                    Text("Tap on any key to edit \nits appearance")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-4)
                    
                    VStack(spacing: 16) {
                        ForEach((0...2), id: \.self) { y in
                            HStack(spacing: 22) {
                                ForEach((0...2), id: \.self) { x in
                                    PasscodeKeyView(face: faces[y * 3 + x + 1], action: { showPicker(y * 3 + x + 1) }, ipadView: ipadView)
                                }
                            }
                        }
                        HStack(spacing: 22) {
                            // import button
                            Button(action: {
                                isImporting = true
                            }) {
                                Image(systemName: "square.and.arrow.down")
                            }
                            .frame(width: 80, height: 80)
                            .scaleEffect(2)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                            
                            // zero key
                            PasscodeKeyView(face: faces[0], action: { showPicker(0) }, ipadView: ipadView)
                            
                            // export key
                            Button(action: {
                                do {
                                    let archiveURL: URL? = try PasscodeKeyFaceManager.exportFaceTheme()
                                    // show share menu
                                    let avc = UIActivityViewController(activityItems: [archiveURL!], applicationActivities: nil)
                                    let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                                    avc.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                                    avc.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                                    UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
                                } catch {
                                    UIApplication.shared.alert(body: "An error occured while exporting key face.")
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .frame(width: 80, height: 80)
                            .scaleEffect(2)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                        }
                    }
                    .padding(.top, 16)
                }
                .offset(x: 0, y: -35)
                VStack {
                    Spacer()
                    if currentSize == -1 {
                        HStack {
                            TextField("X", text: $customSize[0])
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .padding(.horizontal, 5)
                                .font(.system(size: 25))
                                .minimumScaleFactor(0.5)
                                .frame(width: 100, height: 40)
                                .textFieldStyle(PlainTextFieldStyle())
                            Text("x")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(5)
                            TextField("Y", text: $customSize[1])
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .font(.system(size: 25))
                                .minimumScaleFactor(0.5)
                                .frame(width: 100, height: 40)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.bottom, 70)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Button("Reset faces") {
                            do {
                                try PasscodeKeyFaceManager.reset()
                                respring()
                            } catch {
                                UIApplication.shared.alert(body:"An error occured. \(error)")
                            }
                        }
                        Spacer()
                        Button("Choose size") {
                            // create and configure alert controller
                            let alert = UIAlertController(title: "Choose a size", message: "", preferredStyle: .actionSheet)
                            
                            // create the actions
                            let defaultAction = UIAlertAction(title: "Default", style: .default) { (action) in
                                // set the size back to default
                                currentSize = PasscodeKeyFaceManager.getDefaultFaceSize()
                                
                                askToUpdate()
                            }
                            
                            let smallAction = UIAlertAction(title: "Small", style: .default) { (action) in
                                // set the size to small
                                customSize[0] = String(KeySize.small.rawValue)
                                customSize[1] = String(KeySize.small.rawValue)
                                currentSize = -2
                                
                                askToUpdate()
                            }
                            
                            let bigAction = UIAlertAction(title: "Big", style: .default) { (action) in
                                // set the size to big
                                customSize[0] = String(KeySize.big.rawValue)
                                customSize[1] = String(KeySize.big.rawValue)
                                currentSize = -2
                                
                                askToUpdate()
                            }
                            
                            let customAction = UIAlertAction(title: "Custom", style: .default) { (action) in
                                // ask the user for a custom size
                                let sizeAlert = UIAlertController(title: "Enter Key Dimensions", message: "Min: "+String(sizeLimit[0])+", Max: "+String(sizeLimit[1]), preferredStyle: .alert)
                                // bring up the text prompts
                                sizeAlert.addTextField { (textField) in
                                    // text field for width
                                    textField.placeholder = "Width"
                                }
                                sizeAlert.addTextField { (textField) in
                                    // text field for height
                                    textField.placeholder = "Height"
                                }
                                sizeAlert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
                                    // set the sizes
                                    // check if they entered something and if it is in bounds
                                    let width: Int = Int(sizeAlert.textFields?[0].text! ?? "-1") ?? -1
                                    let height: Int = Int(sizeAlert.textFields?[1].text! ?? "-1") ?? -1
                                    if (width >= sizeLimit[0] && width <= sizeLimit[1]) && (height >= sizeLimit[0] && height <= sizeLimit[1]) {
                                        // good to go
                                        customSize[0] = String(width)
                                        customSize[1] = String(height)
                                        currentSize = -1
                                        
                                        askToUpdate()
                                    } else {
                                        // alert that it was not a valid size
                                        UIApplication.shared.alert(body:"Not a valid size!")
                                    }
                                })
                                sizeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                                    // cancel the process
                                })
                                UIApplication.shared.windows.first?.rootViewController?.present(sizeAlert, animated: true, completion: nil)
                            }
                            
                            // determine which to put a check on
                            if currentSize > 0 {
                                defaultAction.setValue(true, forKey: "checked")
                            } else if currentSize == -2 && Int(customSize[0]) == Int(KeySize.small.rawValue) && Int(customSize[1]) == Int(KeySize.small.rawValue) {
                                smallAction.setValue(true, forKey: "checked")
                            } else if currentSize == -2 && Int(customSize[0]) == Int(KeySize.big.rawValue) && Int(customSize[1]) == Int(KeySize.big.rawValue) {
                                bigAction.setValue(true, forKey: "checked")
                            } else {
                                customAction.setValue(true, forKey: "checked")
                            }
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                                // cancels the action
                            }
                            
                            // add the actions
                            alert.addAction(defaultAction)
                            alert.addAction(smallAction)
                            alert.addAction(bigAction)
                            alert.addAction(customAction)
                            alert.addAction(cancelAction)
                            
                            let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                            // present popover for iPads
                            alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                            alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                            
                            // present the alert
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                        }
                        Spacer()
                        Button("Remove all") {
                            do {
                                try PasscodeKeyFaceManager.removeAllFaces()
                                faces = try PasscodeKeyFaceManager.getFaces()
                            } catch {
                                UIApplication.shared.alert(body:"An error occured. \(error)")
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            ipadView = PasscodeKeyFaceManager.getDefaultFaceSize() == KeySize.small.rawValue ? true : false
            currentSize = PasscodeKeyFaceManager.getDefaultFaceSize()
        }
        .fileImporter(isPresented: $isImporting,
                      allowedContentTypes: [
                        //.folder
                        UTType(filenameExtension: "passthm") ?? .zip
                      ],
                      allowsMultipleSelection: false
        ) { result in
            verifySize()
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of file. Did you select it?"); return }
            do {
                // try appying the themes
                try PasscodeKeyFaceManager.setFacesFromTheme(url, keySize: CGFloat(currentSize), customX: CGFloat(Int(customSize[0]) ?? 150), customY: CGFloat(Int(customSize[1]) ?? 150))
                faces = try PasscodeKeyFaceManager.getFaces()
            } catch { UIApplication.shared.alert(body: error.localizedDescription) }
        }
        .onAppear {
            do {
                faces = try PasscodeKeyFaceManager.getFaces()
                
                if let faces = UserDefaults.standard.array(forKey: "changedFaces") as? [Bool] {
                    changedFaces = faces
                }
            } catch {
                UIApplication.shared.alert(body: "An error occured. \(error)")
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: $faces[changingFaceN], didChange: $canChange)
        }
        .onChange(of: faces[changingFaceN] ?? UIImage()) { newValue in
            print(newValue)
            if canChange {
                canChange = false
                // reset the size if too big or small
                verifySize()
                
                do {
                    try PasscodeKeyFaceManager.setFace(newValue, for: changingFaceN, keySize: CGFloat(currentSize), customX: CGFloat(Int(customSize[0]) ?? 150), customY: CGFloat(Int(customSize[1]) ?? 150))
                    faces[changingFaceN] = try PasscodeKeyFaceManager.getFace(for: changingFaceN)
                } catch {
                    UIApplication.shared.alert(body: "An error occured while changing key face. \(error)")
                }
            }
        }
    }
    func showPicker(_ n: Int) {
        changingFaceN = n
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                showingImagePicker = status == .authorized
            }
        }
    }
    
    func askToUpdate() {
        let updateAlert = UIAlertController(title: "Apply for all?", message: "Would you like to apply this size for all currently active keys? Otherwise, it will only apply to new faces.", preferredStyle: .alert)
        
        updateAlert.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            // apply to all
            do {
                try PasscodeKeyFaceManager.setFacesFromTheme(try PasscodeKeyFaceManager.telephonyUIURL(), keySize: CGFloat(-1), customX: CGFloat(Int(customSize[0]) ?? 150), customY: CGFloat(Int(customSize[1]) ?? 150))
                faces = try PasscodeKeyFaceManager.getFaces()
            } catch {
                UIApplication.shared.alert(body:"An error occured when applying face sizes. \(error)")
            }
        })
        
        updateAlert.addAction(UIAlertAction(title: "No", style: .cancel) { (action) in
            // don't apply
        })
        UIApplication.shared.windows.first?.rootViewController?.present(updateAlert, animated: true, completion: nil)
    }
    
    func verifySize() {
        if (Int(customSize[0]) ?? 152 > sizeLimit[1]) {
            // above max size
            customSize[0] = String(sizeLimit[1])
        } else if (Int(customSize[0]) ?? 152 < sizeLimit[0]) {
            // below min size
            customSize[0] = String(sizeLimit[0])
        }
        
        if (Int(customSize[1]) ?? 152 > sizeLimit[1]) {
            // above max size
            customSize[1] = String(sizeLimit[1])
        } else if (Int(customSize[1]) ?? 152 < sizeLimit[0]) {
            // below min size
            customSize[1] = String(sizeLimit[0])
        }
    }
}

struct PasscodeKeyView: View {
    var face: UIImage?
    var action: () -> ()
    var ipadView: Bool
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0.12)))
                    .frame(width: 78, height: 78) // background circle
                Circle()
                    .fill(Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0))) // hidden circle for image
                if face == nil {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    if ipadView {
                        // scale correctly for ipad
                        Image(uiImage: face!)
                            .resizable()
                            .frame(width: CGFloat(Float(face!.size.width)/2.1), height: CGFloat(Float(face!.size.height)/2.1))
                    } else {
                        // normal (for phones)
                        Image(uiImage: face!)
                            .resizable()
                            .frame(width: CGFloat(Float(face!.size.width)/3), height: CGFloat(Float(face!.size.height)/3))
                    }
                }
            }
            .frame(width: 80, height: 80)
        }
    }
}



struct PasscodeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeEditorView()
    }
}
