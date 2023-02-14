//
//  SavedPasscodesView.swift
//  Cowabunga
//
//  Created by lemin on 1/30/23.
//

import SwiftUI

struct SavedPasscodesView: View {
    @Binding var isVisible: Bool
    @Binding var faces: [UIImage?]
    @State var dir: TelephonyDirType
    @State private var savedPasscodesDir = PasscodeKeyFaceManager.getPasscodesDirectory()
    @State private var numOfSaved = 0
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
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
            Text("Saved")
                .padding(.top, 25)
                .font(.largeTitle)
            if numOfSaved == 0 {
                Text("You do not have any saved passcode themes. Check out the explore tab to find some!")
                    .padding()
                    .background(Color(uiColor14: .secondarySystemBackground))
                    .multilineTextAlignment(.center)
                    .cornerRadius(16)
                    .font(.footnote)
                    .foregroundColor(Color(uiColor14: .secondaryLabel))
            } else {
                List {
                    ForEach($savedPasscodesList) { passcode in
                        HStack {
                            Image(uiImage: passcode.passcodeImage.wrappedValue)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 120, maxHeight: 150)
                                .cornerRadius(10, corners: .topLeft)
                                .cornerRadius(10, corners: .topRight)
                                .cornerRadius(10, corners: .bottomLeft)
                                .cornerRadius(10, corners: .bottomRight)
                                .padding(.trailing, 15)
                            
                            Button(action: {
                                // apply passcode file when tapped
                                do {
                                    try PasscodeKeyFaceManager.setFacesFromTheme(passcode.passcodeFile.wrappedValue, dir, colorScheme: colorScheme, keySize: CGFloat(PasscodeKeyFaceManager.getDefaultFaceSize()), customX: 150, customY: 150)
                                    faces = try PasscodeKeyFaceManager.getFaces(dir, colorScheme: colorScheme)
                                    isVisible = false
                                } catch {
                                    print("There was an error applying passcode keys: \(error.localizedDescription)")
                                }
                            }) {
                                Text(passcode.passcodeName.wrappedValue)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(uiColor14: .label))
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            let deletingPasscodeName = savedPasscodesList[i].passcodeName
                            print("Deleting: " + deletingPasscodeName)
                            
                            // delete the file
                            do {
                                let url = savedPasscodesDir!.appendingPathComponent(deletingPasscodeName)
                                try FileManager.default.removeItem(at: url)
                                savedPasscodesList.remove(at: i)
                            } catch {
                                UIApplication.shared.alert(body: "Unable to delete audio for audio \"" + deletingPasscodeName + "\"!")
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
                            let passcodeName: String = passcode.lastPathComponent
                            let passcodeURL: URL? = passcode.appendingPathComponent("\(passcodeName).passthm")
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
