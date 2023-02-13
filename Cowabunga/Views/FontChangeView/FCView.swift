//
//  FCView.swift
//  TrollBox
//
//  Created by Constantin Clerc on 27/12/2022.
//
// Hey there lemin, you still have some work...
// Go at the directory of this file in Finder
// Pick PreviewFonts & RepackedFonts
// Drag and drop to Xcode at this dir (FontChangeView)
// AND TICK FOLDER REFERENCES
// You should be good then

import SwiftUI
import UniformTypeIdentifiers

struct FCView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
            Form {
                progressView
                segmentControl
                if viewModel.fontListSelection == 0 {
                    fontsList
                } else {
                    customFontsList
                }
            }
        .sheet(isPresented: $viewModel.importPresented) {
            WDBDocumentPicker(
                name: viewModel.importName,
                ttcRepackMode: viewModel.importTTCRepackMode) {
                    viewModel.message = $0
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIApplication.shared.confirmAlert(title: "WARNING !", body: "Using this tool on jailbreak and other versions of iOS may be irreversible. More information by clicking Yes.", onOK: {
                        UIApplication.shared.open(URL(string: "https://www.reddit.com/r/jailbreak/comments/zxm9i7/tip_do_not_install_wdbfontoverwrite_via/")!)
                    }, noCancel: false)
                }) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
    
    private var segmentControl: some View {
        Picker("Font choice", selection: $viewModel.fontListSelection) {
            Text("Preset")
                .tag(0)
            Text("Custom")
                .tag(1)
        }
        .pickerStyle(.segmented)
    }
    
    @ViewBuilder
    private var progressView: some View {
            Text(viewModel.message)
        if let progress = viewModel.progress {
            ProgressView(progress)
        }
    }
    
    private var fontsList: some View {
        Section {
            ForEach(viewModel.fonts, id: \.name) { font in
                Button {
                    viewModel.message = "Running"
                    viewModel.progress = Progress(totalUnitCount: 1)
                    overwriteWithFont(
                        name: font.repackedPath,
                        progress: viewModel.progress
                    ) {
                        viewModel.message = $0
                        viewModel.progress = nil
                    }
                } label: {
                    Text(font.name)
                        .font(.custom(
                            font.postScriptName,
                            size: 18)
                        )
                }
            }
        } header: {
            Text("Fonts")
        }
    }
    
    @ViewBuilder
    private var customFontsList: some View {
        Section {
            Picker("Custom font", selection: $viewModel.customFontPickerSelection) {
                ForEach(Array(viewModel.customFonts.enumerated()), id: \.element.name) { index, font in
                    Text(font.name)
                        .tag(index)
                }
            }
            .pickerStyle(.wheel)
        } header: {
            Text("Custom fonts")
        }
        
        Section {
            Button {
                viewModel.message = "Importing..."
                viewModel.importName = viewModel.selectedCustomFont.localPath
                viewModel.importTTCRepackMode = .woff2
                viewModel.importPresented = true
            } label: {
                Text("Import custom \(viewModel.selectedCustomFont.name)")
            }
            if let alternativeTTCRepackMode = viewModel.selectedCustomFont.alternativeTTCRepackMode  {
                Button {
                    viewModel.message = "Importing..."
                    viewModel.importName = viewModel.selectedCustomFont.localPath
                    viewModel.importTTCRepackMode = alternativeTTCRepackMode
                    viewModel.importPresented = true
                } label: {
                    Text("Import custom \(viewModel.selectedCustomFont.name) with fix for .ttc")
                }
            }
            Button {
                viewModel.message = "Running"
                viewModel.progress = Progress(totalUnitCount: 1)
                overwriteWithCustomFont(
                    name: viewModel.selectedCustomFont.localPath,
                    targetName: viewModel.selectedCustomFont.targetPath,
                    progress: viewModel.progress
                ) {
                    viewModel.message = $0
                    viewModel.progress = nil
                }
            } label: {
                Text("Apply \(viewModel.selectedCustomFont.name)")
            }
        }
    }
}

struct FCView_Previews: PreviewProvider {
    static var previews: some View {
        FCView()
    }
}
