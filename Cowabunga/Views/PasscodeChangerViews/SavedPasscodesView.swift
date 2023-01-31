//
//  SavedPasscodesView.swift
//  Cowabunga
//
//  Created by lemin on 1/30/23.
//

import SwiftUI

struct SavedPasscodesView: View {
    @State private var savedPasscodesDir = PasscodeKeyFaceManager.getPasscodesDirectory()
    @State private var numOfSaved = 0
    
    // passcode file
    struct PasscodeFile: Identifiable {
        var id = UUID()
        var passcodeName: String
        var passcodeImage: UIImage
        var passcodeFile: URL
    }
    
    // list of passcode files
    @State var savedPasscodesList: [PasscodeFile] = [
    ]
    
    var body: some View {
        VStack {
            if numOfSaved == 0 {
                Text("You do not have any saved passcode themes. Check out the explore tab to find some!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach($savedPasscodesList) { passcode in
                        HStack {
                            Image(uiImage: passcode.passcodeImage.wrappedValue)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 40, maxHeight: 40)
                                .cornerRadius(10, corners: .topLeft)
                                .cornerRadius(10, corners: .topRight)
                            
                            Button(action: {
                                // apply passcode file when tapped
                                do {
                                    try PasscodeKeyFaceManager.setFacesFromTheme(passcode.passcodeFile.wrappedValue, keySize: CGFloat(PasscodeKeyFaceManager.getDefaultFaceSize()), customX: 150, customY: 150)
                                } catch {
                                    print("There was an error applying passcode keys: \(error.localizedDescription)")
                                }
                            }) {
                                Text(passcode.passcodeName.wrappedValue)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 24, weight: .bold))
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            do {
                if savedPasscodesDir != nil {
                    numOfSaved = try FileManager.default.contentsOfDirectory(at: savedPasscodesDir!, includingPropertiesForKeys: nil).count
                    
                    if numOfSaved > 0 {
                        for passcode in try FileManager.default.contentsOfDirectory(at: savedPasscodesDir!, includingPropertiesForKeys: nil) {
                            let passcodeURL: URL? = passcode.appendingPathComponent("theme.passthm")
                            let passcodeName: String = passcode.lastPathComponent.replacingOccurrences(of: "_", with: " ")
                            let passcodeImage: URL? = passcode.appendingPathComponent("preview.png")
                            if passcodeURL != nil && passcodeImage != nil {
                                do {
                                    let imgData = try Data(contentsOf: passcodeImage!)
                                    let uiImg = UIImage(data: imgData)
                                    if uiImg != nil {
                                        savedPasscodesList.append(PasscodeFile.init(passcodeName: passcodeName, passcodeImage: uiImg!, passcodeFile: passcodeURL!))
                                    }
                                } catch {
                                    print("Error getting image data: \(error.localizedDescription)")
                                    continue
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error getting contents of directory")
            }
        }
    }
}

struct SavedPasscodesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedPasscodesView()
    }
}
