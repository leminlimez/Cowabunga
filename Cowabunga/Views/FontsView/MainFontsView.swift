//
//  MainFontsView.swift
//  Cowabunga
//
//  Created by lemin on 2/16/23.
//

import SwiftUI

struct FontPack: Identifiable {
    var id = UUID()
    var name: String
    var enabled: Bool = false
}

struct MainFontsView: View {
    @State private var fontOptions: [FontPack] = [
        .init(name: "None", enabled: true)
    ]
    
    var body: some View {
        VStack {
            List {
                ForEach($fontOptions) { option in
                    HStack {
                        if option.name.wrappedValue != "None" {
                            NavigationLink(destination: EditingFontView(fontPackName: option.name.wrappedValue)) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .opacity(option.enabled.wrappedValue ? 1 : 0)
                                    Text(option.name.wrappedValue)
                                        .padding(.horizontal, 8)
                                }
                            }
                        } else {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .opacity(option.enabled.wrappedValue ? 1 : 0)
                            Text(option.name.wrappedValue)
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        let deletingFolderName = fontOptions[i].name
                        print("Deleting: " + deletingFolderName)
                        // delete the folder
                        do {
                            try FontManager.deleteFontPack(deletingFolderName)
                            fontOptions.remove(at: i)
                        } catch {
                            UIApplication.shared.alert(title: NSLocalizedString("Failed to delete font pack!", comment: ""), body: error.localizedDescription)
                        }
                    }
                }
            }
            .toolbar {
                Button(action: {
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
                }
            }
            .onAppear {
                do {
                    fontOptions.append(contentsOf: try FontManager.getFontPacks())
                } catch {
                    UIApplication.shared.alert(title: NSLocalizedString("There was an error getting font packs.", comment: "loading font packs"), body: error.localizedDescription)
                }
            }
        }
    }
}
