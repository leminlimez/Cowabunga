//
//  EditingOperationView.swift
//  Cowabunga
//
//  Created by lemin on 2/8/23.
//

import SwiftUI

struct PlistProperty: Identifiable {
    var id = UUID()
    var key: String
    var oldKey: String
    var value: Any
}

struct EditingOperationView: View {
    var category: String
    var editing: Bool
    @State var operation: AdvancedObject
    
    // basic properties
    @State var operationName: String = ""
    @State var filePath: String = ""
    @State var applyInBackground: Bool = false
    @State var previousName: String = ""
    
    // replacing properties
    @State var savedFilePath: String = "/"
    
    @State var replacingType: ReplacingObjectType = ReplacingObjectType.Imported
    @State var replacingPath: String = ""
    @State var replacingData: Data? = nil
    @State var backupData: Data? = nil
    
    // plist properties
    @State var plistType: PropertyListSerialization.PropertyListFormat = .xml
    @State var replacingKeys: [String: Any] = [:]
    @State var plistKeys: [PlistProperty] = []
    @State var calculatedSize: Int? = nil
    
    @State var isImporting: Bool = false
    @State var pageTitle: String = ""
    
    var body: some View {
        VStack {
            List {
                Section {
                    // MARK: Operation Name
                    HStack {
                        Text("Name:")
                            .bold()
                        Spacer()
                        if #available(iOS 15.0, *) {
                            TextField("Operation Name", text: $operationName)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                        } else {
                            // Fallback on earlier versions
                            TextField("Operation Name", text: $operationName)
                                .multilineTextAlignment(.trailing)
                        }
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
                            if #available(iOS 15, *) {
                                alert.addAction(plistAction)
                            }
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
                            } else if operation is PlistObject {
                                Text("Plist")
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
                            if #available(iOS 15.0, *) {
                                TextField("Path", text: $filePath)
                                    .multilineTextAlignment(.trailing)
                                    .submitLabel(.done)
                                    .frame(maxHeight: 180)
                            } else {
                                // Fallback on earlier versions
                                TextEditor(text: $filePath)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxHeight: 180)
                            }
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
                                    if #available(iOS 15.0, *) {
                                        TextEditor(text: $replacingPath)
                                            .multilineTextAlignment(.trailing)
                                            .submitLabel(.done)
                                            .frame(maxHeight: 180)
                                    } else {
                                        // Fallback on earlier versions
                                        TextEditor(text: $replacingPath)
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxHeight: 180)
                                    }
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
                                    Text(splitted.last ?? "No file selected!")
                                        .multilineTextAlignment(.trailing)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    if replacingData != nil {
                                        Text("\(replacingData!.count) bytes")
                                            .multilineTextAlignment(.trailing)
                                            .padding(.bottom, 10)
                                    } else {
                                        Text("File not found!")
                                            .multilineTextAlignment(.trailing)
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    isImporting.toggle()
                                }) {
                                    Text("Upload File")
                                        .foregroundColor(.blue)
                                        .multilineTextAlignment(.trailing)
                                }
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
                                Text((plistType == PropertyListSerialization.PropertyListFormat.xml) ? "xml": "binary")
                                    .multilineTextAlignment(.trailing)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        // MARK: Plist Size
                        HStack {
                            Spacer()
                            if calculatedSize != nil {
                                Text("\(calculatedSize!) bytes")
                                    .multilineTextAlignment(.trailing)
                            } else {
                                Text("Size not calculated")
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                if let plistOperation = operation as? PlistObject {
                                    plistOperation.filePath = filePath
                                    plistOperation.plistType = plistType
                                    plistOperation.replacingKeys = replacingKeys
                                    do {
                                        try plistOperation.parseData()
                                        calculatedSize = plistOperation.replacementData!.count
                                    } catch {
                                        UIApplication.shared.alert(title: NSLocalizedString("Could not calculate plist size!", comment: ""), body: error.localizedDescription)
                                    }
                                }
                            }) {
                                Text("Calculate Size")
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    } header: {
                        Text("Plist Properties")
                    }
                    
                    Section {
                        // MARK: Add Property Button
                        HStack {
                            Spacer()
                            Button(action: {
                                var newKeyID: Int = 1
                                while replacingKeys["New Key \(newKeyID)"] != nil {
                                    newKeyID += 1
                                }
                                let kn = "New Key \(newKeyID)"
                                let nv = "New Value"
                                replacingKeys[kn] = nv
                                plistKeys.insert(.init(key: kn, oldKey: kn, value: nv), at: 0)
                            }) {
                                Text("Add Value")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        
                        // MARK: List of Properties
                        if #available(iOS 15, *) {
                            ForEach($plistKeys) { plist in
                                NavigationLink(destination: PlistEditView(plistKey: plist.key, plistValue: plist.value)) {
                                    HStack {
                                        Text(plist.key.wrappedValue)
                                            .bold()
                                        Spacer()
                                        Text(String(describing: plist.value.wrappedValue))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { i in
                                    let deletingProperty = plistKeys[i].key
                                    replacingKeys[deletingProperty] = nil
                                }
                            }
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
                                try AdvancedManager.deleteOperation(operationName: previousName)
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
                        } else {
                            // MARK: Delete
                            Button(action: {
                                // apply the changes
                                UIApplication.shared.alert(title: NSLocalizedString("Deleting operation...", comment: "delete button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
                                do {
                                    try AdvancedManager.deleteOperation(operationName: previousName)
                                    UIApplication.shared.dismissAlert(animated: true)
                                    UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully deleted!", comment: "when an operation is deleted"))
                                } catch {
                                    UIApplication.shared.dismissAlert(animated: true)
                                    UIApplication.shared.alert(body: NSLocalizedString("An error occurred while deleting the operation", comment: "when an operation fails to delete") + ": \(error.localizedDescription)")
                                }
                            }) {
                                Text("Delete")
                            }
                            .buttonStyle(FullwidthTintedButton(color: .red))
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
            }
            .navigationTitle(pageTitle)
            .onAppear {
                pageTitle = editing ? "Edit Operation": "Create Operation"
                operationName = operation.operationName
                previousName = operationName
                filePath = operation.filePath
                applyInBackground = operation.applyInBackground
                
                if let replacingOperation = operation as? ReplacingObject {
                    replacingType = replacingOperation.replacingType
                    replacingPath = replacingOperation.replacingPath
                } else if let plistOperation = operation as? PlistObject {
                    plistType = plistOperation.plistType
                    if replacingKeys.count == 0 {
                        // populate plist
                        replacingKeys = plistOperation.replacingKeys
                        for (k, v) in replacingKeys {
                            plistKeys.append(.init(key: k, oldKey: k, value: v))
                        }
                    }
                }
                
                replacingKeys.removeAll(keepingCapacity: true)
                
                for (_, plist) in plistKeys.enumerated() {
                    replacingKeys[plist.key] = plist.value
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
        } else if operation is PlistObject, let operation = operation as? PlistObject {
            operation.replacingKeys = replacingKeys
            operation.plistType = plistType
        }
    }
}
