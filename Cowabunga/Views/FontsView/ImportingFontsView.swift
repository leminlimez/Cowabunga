//
//  ImportingFontsView.swift
//  Cowabunga
//
//  Created by lemin on 2/23/23.
//

import SwiftUI

struct ImportingFontsView: View {
    @Binding var isVisible: Bool
    @Binding var openingURL: URL?
    @State private var fontOptions: [FontPack] = []
    
    var body: some View {
        VStack {
            VStack (alignment: .leading) {
                HStack {
                    Text("Select Font Pack")
                        .font(.largeTitle)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                    
                    Spacer()
                    
                    // MARK: New Font Button
                    Button(action: {
                        // copy and paste code :trollface:
                        // create a new font pack
                        // ask for a name for the font pack
                        let alert = UIAlertController(title: NSLocalizedString("Enter Name", comment: ""), message: NSLocalizedString("Choose a name for the font pack", comment: ""), preferredStyle: .alert)
                        
                        // bring up the text prompts
                        alert.addTextField { (textField) in
                            // text field for width
                            textField.placeholder = NSLocalizedString("Name", comment: "")
                        }
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { (action) in
                            // set the name and add the file
                            if alert.textFields?[0].text != nil {
                                // check if it is a valid name
                                var fileName: String = (alert.textFields?[0].text ?? "Unnamed").replacingOccurrences(of: ".", with: "")
                                if fileName == "" || fileName == "None" {
                                    // set to unnamed
                                    fileName = "Unnamed"
                                }
                                // save the folder
                                do {
                                    try FontManager.createFontPackFolder(fileName)
                                    fontOptions.append(.init(name: fileName))
                                    UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The font pack folder was successfully created.", comment: "Creating font pack"))
                                } catch {
                                    print(error.localizedDescription)
                                    UIApplication.shared.alert(title: NSLocalizedString("Unable to create font pack!", comment: "Failed to create font pack"), body: error.localizedDescription)
                                }
                            } else {
                                print("alert textfield is nil!")
                                UIApplication.shared.alert(body: "Unexpected error with textfield")
                            }
                        })
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                            // cancel the process
                        })
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .padding(.horizontal, 5)
                            .padding(.bottom, 5)
                            .padding(.top, 20)
                            .font(.title2)
                    }
                    
                    // MARK: Import Button
                    Button(action: {
                        var failed: [String: String] = [:]
                        for fontOption in fontOptions {
                            if fontOption.enabled {
                                do {
                                    let _ = try FontManager.addFontFileToPack(pack: fontOption.name, file: openingURL!)
                                } catch {
                                    failed[fontOption.name] = error.localizedDescription
                                }
                            }
                        }
                        // show the error message if there is one, otherwise close the ui
                        if failed.count > 0 {
                            var str: String = ""
                            for (k, e) in failed {
                                str += "\(k): \(e)\n"
                            }
                            UIApplication.shared.alert(title: NSLocalizedString("Failed to import font files!", comment: ""), body: str)
                        } else {
                            // success
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.blue)
                            .padding(.trailing, 40)
                            .padding(.top, 20)
                            .padding(.bottom, 5)
                            .font(.title2)
                    }
                }
                Text("If a file of the same name already exists in the pack, it will be overwritten.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2)
                    .multilineTextAlignment(.leading)
            }
            
            List {
                ForEach($fontOptions) { pack in
                    Button(action: {
                        pack.enabled.wrappedValue.toggle()
                    }) {
                        HStack {
                            Text(pack.name.wrappedValue)
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(pack.enabled.wrappedValue ? 1 : 0)
                        }
                    }
                }
            }
        }
        .onAppear {
            do {
                fontOptions = try FontManager.getFontPacks()
            } catch {
                UIApplication.shared.alert(title: NSLocalizedString("There was an error getting font packs.", comment: "loading font packs"), body: error.localizedDescription)
            }
        }
    }
}
