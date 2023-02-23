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
                    
                } header: {
                    Text("Font Files")
                }
            }
        }
    }
}
