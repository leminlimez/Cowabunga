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
    @State private var isImporting: Bool = false
    @State private var currentFont: String = UserDefaults.standard.string(forKey: "SelectedFont") ?? "None"
    
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
                                        UserDefaults.standard.set(fontPackName, forKey: "SelectedFont")
                                        currentFont = fontPackName
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
                    if currentFont == fontPackName {
                        Text("Active")
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.green)
                    } else {
                        Button(action: {
                            UserDefaults.standard.set(fontPackName, forKey: "SelectedFont")
                            currentFont = fontPackName
                        }) {
                            Text("Set as Active")
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.blue)
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
                    isImporting.toggle()
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .sheet(isPresented: $isImporting) {
                DocumentPicker(
                    types: [
                        UTType(filenameExtension: "ttf") ?? .font,
                        UTType(filenameExtension: "ttc") ?? .font
                    ], allowsMultipleSelection: true) { result in
                        // user chose a file
                        if result.first == nil {
                            UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of file. Did you select it?", comment: ""))
                            return
                        }
                        var failed: [String: String] = [:]
                        for url in result {
                            guard url.startAccessingSecurityScopedResource() else { failed[url.lastPathComponent] = "File permission error"; continue }
                            
                            do {
                                let newFontFile = try FontManager.addFontFileToPack(pack: fontPackName, file: url)
                                fontFiles.append(newFontFile)
                                url.stopAccessingSecurityScopedResource()
                            } catch {
                                failed[url.lastPathComponent] = error.localizedDescription
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                        if failed.count > 0 {
                            var str: String = ""
                            for (k, e) in failed {
                                str += "\(k): \(e)\n"
                            }
                            UIApplication.shared.alert(title: NSLocalizedString("Failed to import font files!", comment: ""), body: str)
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
