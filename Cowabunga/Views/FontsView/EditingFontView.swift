//
//  EditingFontView.swift
//  Cowabunga
//
//  Created by lemin on 2/22/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct FontFile: Identifiable {
    var id = UUID()
    var name: String
}

struct EditingFontView: View {
    @State var fontPackName: String
    @State var newFontPackName: String = ""
    
    @State var fontFiles: [FontFile] = [
    ]
    @State var isImporting: Bool = false
    
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
                    
                    // MARK: Enable Font
                    
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
                    isImporting.toggle()
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .sheet(isPresented: $isImporting) {
                DocumentPicker(
                    types: [
                        UTType(filenameExtension: "ttf") ?? .font
                    ]) { result in
                        // user chose a file
                        if result.first == nil {
                            UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of file. Did you select it?", comment: ""))
                            return
                        }
                        let url: URL = result.first!
                        guard url.startAccessingSecurityScopedResource() else { UIApplication.shared.alert(body: "File permission error"); return }
                        
                        do {
                            let newFontFile = try FontManager.addFontFileToPack(pack: fontPackName, file: url)
                            fontFiles.append(newFontFile)
                            url.stopAccessingSecurityScopedResource()
                        } catch {
                            UIApplication.shared.alert(title: NSLocalizedString("Failed to import font file!", comment: ""), body: error.localizedDescription)
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
            }
            .onAppear {
                newFontPackName = fontPackName
                // get the font files
                do {
                    fontFiles = try FontManager.getFontPackFiles(fontPackName)
                } catch {
                    UIApplication.shared.alert(title: NSLocalizedString("Failed to fetch font pack files!", comment: ""), body: error.localizedDescription)
                }
            }
        }
    }
}
