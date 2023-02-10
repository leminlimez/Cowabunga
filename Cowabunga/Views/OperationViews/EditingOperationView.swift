//
//  EditingOperationView.swift
//  Cowabunga
//
//  Created by lemin on 2/8/23.
//

import SwiftUI

struct EditingOperationView: View {
    var category: String
    var editing: Bool
    @State var operation: AdvancedObject
    
    // basic properties
    @State var operationName: String = ""
    @State var filePath: String = ""
    @State var applyInBackground: Bool = false
    
    // replacing properties
    @State var savedFilePath: String = "/"
    
    @State var replacingType: ReplacingObjectType = ReplacingObjectType.Imported
    @State var replacingPath: String = ""
    @State var replacingData: Data? = nil
    @State var backupData: Data? = nil
    
    // plist properties
    @State var plistType: PropertyListSerialization.PropertyListFormat = .xml
    @State var replacingKeys: [String: Any] = [:]
    
    @State var isImporting: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section {
                    // MARK: Operation Name
                    HStack {
                        Text("Name:")
                            .bold()
                        Spacer()
                        TextField("Operation Name", text: $operationName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // MARK: Operation Type
                    HStack {
                        Text("Type:")
                            .bold()
                        Spacer()
                        Button(action: {
                            // create and configure alert controller
                            let alert = UIAlertController(title: NSLocalizedString("Choose an operation type", comment: ""), message: "", preferredStyle: .actionSheet)
                            
                            // create the actions
                            let corruptingAction = UIAlertAction(title: NSLocalizedString("Corrupting", comment: "operation type that corrupts/disables the file"), style: .default) { (action) in
                                // change the type
                                if !(operation is CorruptingObject) {
                                    operation = CorruptingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground)
                                }
                            }
                            
                            let replacingAction = UIAlertAction(title: NSLocalizedString("Replacing", comment: "operation type that replaces a file"), style: .default) { (action) in
                                // change the type
                                if !(operation is ReplacingObject) {
                                    operation = ReplacingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, overwriteData: Data("#".utf8), replacingType: ReplacingObjectType.Imported, replacingPath: "/Unknown")
                                }
                            }
                            
                            let plistAction = UIAlertAction(title: NSLocalizedString("Plist", comment: "operation type that changes plist keys"), style: .default) { (action) in
                                // change the type
                                if !(operation is PlistObject) {
                                    operation = PlistObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, plistType: plistType, replacingKeys: replacingKeys)
                                    //operation = CorruptingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground)
                                }
                            }
                            
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                // cancels the action
                            }
                            
                            // add the actions
                            alert.addAction(corruptingAction)
                            alert.addAction(replacingAction)
                            //alert.addAction(plistAction)
                            alert.addAction(cancelAction)
                            
                            let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                            // present popover for iPads
                            alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                            alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                            
                            // present the alert
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                        }) {
                            // get the type of operation
                            if operation is CorruptingObject {
                                Text("Corrupting")
                                    .foregroundColor(.blue)
                            } else if operation is ReplacingObject {
                                Text("Replacing")
                                    .foregroundColor(.blue)
                            } else {
                                Text("????")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                } header: {
                    Text("Basic Configuration")
                }
                
                Section {
                    // MARK: File Path
                    VStack {
                        HStack {
                            Text("Path:")
                                .bold()
                            Spacer()
                            TextEditor(text: $filePath)
                                .multilineTextAlignment(.trailing)
                                .frame(maxHeight: 180)
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            if FileManager.default.fileExists(atPath: filePath), let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                                Text("\(fileData.count) bytes")
                                    .multilineTextAlignment(.trailing)
                                    .padding(.bottom, 10)
                            } else {
                                Text("File not found!")
                                    .multilineTextAlignment(.trailing)
                                    .padding(.bottom, 10)
                            }
                        }
                    }
                    
                    // MARK: Applying in Background
                    HStack {
                        Text("Apply in Background")
                            .bold()
                        Spacer()
                        Toggle(isOn: $applyInBackground) {}
                    }
                } header: {
                    Text("Action")
                }
                
                // MARK: Replacing Object Properties
                if operation is ReplacingObject {
                    Section {
                        // MARK: Replacement Type
                        HStack {
                            Text("Replace With:")
                                .bold()
                            Spacer()
                            Button(action: {
                                // create and configure alert controller
                                let alert = UIAlertController(title: NSLocalizedString("Choose an operation type", comment: ""), message: "", preferredStyle: .actionSheet)
                                
                                // create the actions
                                for tp in ReplacingObjectType.allCases {
                                    let newAction = UIAlertAction(title: tp.rawValue, style: .default) { (action) in
                                        if tp != replacingType {
                                            let tmp = replacingPath
                                            replacingPath = savedFilePath
                                            savedFilePath = replacingPath
                                            
                                            if tp == ReplacingObjectType.FilePath {
                                                backupData = replacingData
                                                replacingData = nil
                                            } else if tp == ReplacingObjectType.Imported {
                                                replacingData = backupData
                                                backupData = nil
                                            }
                                        }
                                        replacingType = tp
                                    }
                                    alert.addAction(newAction)
                                }
                                
                                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                    // cancels the action
                                }
                                
                                // add the actions
                                alert.addAction(cancelAction)
                                
                                let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                                // present popover for iPads
                                alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                                alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                                
                                // present the alert
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                            }) {
                                Text(replacingType.rawValue)
                                    .multilineTextAlignment(.trailing)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        // MARK: Replacement File Path
                        if replacingType == ReplacingObjectType.FilePath {
                            VStack {
                                HStack {
                                    Text("Path:")
                                        .bold()
                                    Spacer()
                                    TextEditor(text: $replacingPath)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxHeight: 180)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    if FileManager.default.fileExists(atPath: replacingPath), let fileData = try? Data(contentsOf: URL(fileURLWithPath: replacingPath)) {
                                        Text("\(fileData.count) bytes")
                                            .multilineTextAlignment(.trailing)
                                            .padding(.bottom, 10)
                                    } else {
                                        Text("File not found!")
                                            .multilineTextAlignment(.trailing)
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                        } else if replacingType == ReplacingObjectType.Imported, let splitted = replacingPath.split(separator: "/") {
                            VStack {
                                HStack {
                                    Text("File:")
                                        .bold()
                                    Spacer()
                                    Text(splitted.last ?? "Error")
                                        .multilineTextAlignment(.trailing)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    if FileManager.default.fileExists(atPath: filePath), let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                                        Text("\(fileData.count) bytes")
                                            .multilineTextAlignment(.trailing)
                                            .padding(.bottom, 10)
                                    } else {
                                        Text("File not found!")
                                            .multilineTextAlignment(.trailing)
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                            Button(action: {
                                isImporting.toggle()
                            }) {
                                Text("Upload File")
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    } header: {
                        Text("Replacement Data")
                    }
                }
                
                // MARK: Plist Object Operation
                if operation is PlistObject {
                    Section {
                        // MARK: Plist Type
                        HStack {
                            Text("Plist Type:")
                                .bold()
                            Spacer()
                            Button(action: {
                                // create and configure alert controller
                                let alert = UIAlertController(title: NSLocalizedString("Choose a plist type", comment: ""), message: "", preferredStyle: .actionSheet)
                                
                                // create the actions
                                let xmlAction = UIAlertAction(title: "xml", style: .default) { (action) in
                                    plistType = .xml
                                }
                                let binaryAction = UIAlertAction(title: "binary", style: .default) { (action) in
                                    plistType = .binary
                                }
                                
                                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                    // cancels the action
                                }
                                
                                // add the actions
                                alert.addAction(xmlAction)
                                alert.addAction(binaryAction)
                                alert.addAction(cancelAction)
                                
                                let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                                // present popover for iPads
                                alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                                alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                                
                                // present the alert
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                            }) {
                                Text(replacingType.rawValue)
                                    .multilineTextAlignment(.trailing)
                            }
                            .foregroundColor(.blue)
                        }
                    } header: {
                        Text("Plist Data")
                    }
                }
                
                // MARK: Operation Actions
                Section {
                    VStack {
                        // MARK: Save
                        Button(action: {
                            // apply the changes
                            UIApplication.shared.alert(title: NSLocalizedString("Saving operation...", comment: "apply button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
                            applyOperationProperties()
                            do {
                                try AdvancedManager.saveOperation(operation: operation, category: category, replacingFileData: replacingData)
                                UIApplication.shared.dismissAlert(animated: true)
                                UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully saved!", comment: "when an operation is saved"))
                            } catch {
                                UIApplication.shared.dismissAlert(animated: true)
                                UIApplication.shared.alert(body: NSLocalizedString("An error occurred while saving the operation", comment: "when an operation fails to save") + ": \(error.localizedDescription)")
                            }
                        }) {
                            if editing {
                                Text("Save")
                            } else {
                                Text("Create")
                            }
                        }
                        .buttonStyle(FullwidthTintedButton(color: .blue))
                        
                        // MARK: Apply Once
                        if !editing {
                            Button("Apply Once") {
                                // apply the operation
                                UIApplication.shared.alert(title: NSLocalizedString("Applying operation...", comment: "apply button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
                                applyOperationProperties()
                                do {
                                    try operation.parseData()
                                    try operation.applyData()
                                    UIApplication.shared.dismissAlert(animated: true)
                                    UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully applied! The operation was not saved, only applied.", comment: "when an operation is applied"))
                                } catch {
                                    UIApplication.shared.dismissAlert(animated: true)
                                    UIApplication.shared.alert(body: NSLocalizedString("An error occurred while applying the operation", comment: "when an operation fails to apply") + ": \(error.localizedDescription)")
                                }
                            }
                            .buttonStyle(FullwidthTintedButton(color: .blue))
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
            }
            .navigationTitle("Edit Operation")
            .onAppear {
                operationName = operation.operationName
                filePath = operation.filePath
                applyInBackground = operation.applyInBackground
                
                if let replacingOperation = operation as? ReplacingObject {
                    replacingType = replacingOperation.replacingType
                    replacingPath = replacingOperation.replacingPath
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                guard let url = try? result.get().first else { UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of file. Did you select it?", comment: "")); return }
                guard url.startAccessingSecurityScopedResource() else { UIApplication.shared.alert(body: "File permission error"); return }
                
                // save to temp directory
                do {
                    let tmp = FileManager.default.temporaryDirectory
                    replacingData = try Data(contentsOf: url)
                    let newURL = tmp.appendingPathComponent(url.lastPathComponent)
                    // write to temp file
                    try replacingData!.write(to: newURL)
                    replacingPath = newURL.path
                    url.stopAccessingSecurityScopedResource()
                } catch {
                    UIApplication.shared.alert(body: NSLocalizedString("An error occurred", comment: "") + ": \(error.localizedDescription)")
                    url.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    func applyOperationProperties() {
        // set the properties of the operation
        operation.operationName = operationName
        operation.filePath = filePath
        operation.applyInBackground = applyInBackground
        if operation is ReplacingObject, let operation = operation as? ReplacingObject {
            operation.replacingType = replacingType
            operation.replacingPath = replacingPath
        }
    }
}
