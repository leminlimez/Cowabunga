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
                            TextField("Font Pack Name", text: $fontPackName)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                        } else {
                            // Fallback on earlier versions
                            TextField("Font Pack Name", text: $fontPackName)
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
                        }
                    }
                } header: {
                    Text("Font Files")
                }
            }
        }
    }
}
