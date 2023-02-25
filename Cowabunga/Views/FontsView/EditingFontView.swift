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
                                    if newFontPackName != fontPackName {
                                        do {
                                            try FontManager.renameFontPack(old: fontPackName, new: newFontPackName)
                                            if currentFont == fontPackName {
                                                UserDefaults.standard.set(newFontPackName, forKey: "SelectedFont")
                                                currentFont = newFontPackName
                                            }
                                            fontPackName = newFontPackName
                                        } catch {
                                            newFontPackName = fontPackName
                                            UIApplication.shared.alert(title: NSLocalizedString("Failed to rename font pack!", comment: ""), body: error.localizedDescription)
                                        }
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
                        UTType(filenameExtension: "ttc") ?? .font,
                        UTType(filenameExtension: "otf") ?? .font
                    ], allowsMultipleSelection: true) { result in
                        // user chose a file
                        if result.first == nil {
                            UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of file. Did you select it?", comment: ""))
                            return
                        }
                        var failed: [String: String] = [:]
                        for url in result {
                            guard url.startAccessingSecurityScopedResource() else { failed[url.lastPathComponent] = "File permission error"; continue }
                            
                            // verify name
                            if FontManager.verifyName(fileName: url.lastPathComponent) {
                                do {
                                    let newFontFile = try FontManager.addFontFileToPack(pack: fontPackName, file: url)
                                    fontFiles.append(newFontFile)
                                } catch {
                                    failed[url.lastPathComponent] = error.localizedDescription
                                }
                            } else {
                                let newFileName: String = url.pathExtension == "ttc" ? "SFUISoft.ttc" : "SFUI.ttf"
                                UIApplication.shared.confirmAlert(title: NSLocalizedString("Font \"\(url.lastPathComponent)\" not correctly named!", comment: ""), body: NSLocalizedString("Would you like to import it to replace the default font (\(newFileName))?", comment: "when the font file is not correctly named"), onOK: {
                                    // rename
                                    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(newFileName)
                                    do {
                                        if FileManager.default.fileExists(atPath: tmpDir.path) {
                                            try FileManager.default.removeItem(at: tmpDir)
                                        }
                                        let fontData: Data = try Data(contentsOf: url)
                                        try fontData.write(to: tmpDir)
                                        
                                        let newFontFile = try FontManager.addFontFileToPack(pack: fontPackName, file: tmpDir)
                                        fontFiles.append(newFontFile)
                                    } catch {
                                        failed[url.lastPathComponent] = error.localizedDescription
                                    }
                                }, noCancel: false)
                            }
                            url.stopAccessingSecurityScopedResource()
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
                if newFontPackName == "" {
                    newFontPackName = fontPackName
                }
                // get the font files
                do {
                    fontFiles = try FontManager.getFontPackFiles(fontPackName)
                } catch {
                    // backup: check new font pack name
                    do {
                        fontFiles = try FontManager.getFontPackFiles(newFontPackName)
                    } catch {
                        UIApplication.shared.alert(title: NSLocalizedString("Failed to fetch font pack files!", comment: ""), body: error.localizedDescription)
                    }
                }
            }
        }
        .navigationTitle("Editing \(fontPackName)")
    }
}
