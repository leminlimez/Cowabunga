//
//  EditingFontView.swift
//  Cowabunga
//
//  Created by lemin on 2/22/23.
//

import SwiftUI

struct EditingFontView: View {
    struct FontFile: Identifiable {
        var id = UUID()
        var name: String
    }
    
    @State var fontPackName: String
    @State var newFontPackName: String = ""
    
    @State var fontFiles: [FontFile] = [
    ]
    
    var body: some View {
        VStack {
            List {
                Section {
                    // MARK: Font Pack Name
                    HStack {
                        Text("Name:")
                            .bold()
                        Spacer()
                        if #available(iOS 15.0, *) {
                            TextField("Font Pack Name", text: $newFontPackName)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                                .onSubmit {
                                    do {
                                        try FontManager.renameFontPack(old: fontPackName, new: newFontPackName)
                                        fontPackName = newFontPackName
                                    } catch {
                                        newFontPackName = fontPackName
                                        UIApplication.shared.alert(title: NSLocalizedString("Failed to rename font pack!", comment: ""), body: error.localizedDescription)
                                    }
                                }
                        } else {
                            // Fallback on earlier versions
                            TextField("Font Pack Name", text: $newFontPackName)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } header: {
                    Text("Configuration")
                }
                
                Section {
                    ForEach($fontFiles) { font in
                        Text(font.name.wrappedValue)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            let deletingFileName = fontFiles[i].name
                            print("Deleting: " + deletingFileName)
                            // delete the file
                            do {
                                try FontManager.deleteFontFile(deletingFileName, fontPackName)
                                fontFiles.remove(at: i)
                            } catch {
                                UIApplication.shared.alert(title: NSLocalizedString("Failed to delete font file!", comment: ""), body: error.localizedDescription)
                            }
                        }
                    }
                } header: {
                    Text("Font Files")
                }
            }
            .toolbar {
                Button(action: {
                    // import font file
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .onAppear {
                newFontPackName = fontPackName
            }
        }
    }
}
