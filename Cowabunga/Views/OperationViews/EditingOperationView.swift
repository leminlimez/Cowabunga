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
    @State var previousFilePath: String = ""
    @State var filePath: String = ""
    @State var applyInBackground: Bool = false
    @State var previousName: String = ""
    @State var isActive: Bool = false
    
    // replacing properties
    @State var savedFilePath: String = "/"
    
    @State var replacingType: ReplacingObjectType = ReplacingObjectType.Imported
    @State var replacingPath: String = ""
    @State var replacingData: Data? = nil
    @State var backupData: Data? = nil
    
    private let hasPadding: [String] = [
            "plist",
            "strings",
            "loctable",
            "materialrecipe",
            "visualstyleset"
        ]
        @State var showPaddingButton: Bool = false
    
    // plist properties
    @State var plistType: PropertyListSerialization.PropertyListFormat = .xml
    @State var replacingKeys: [String: Any] = [:]
    @State var plistKeys: [PlistProperty] = []
    @State var calculatedSize: Int? = nil
    
    @State var isImporting: Bool = false
    @State var pageTitle: String = ""
    
    // color properties
    @State var changingColor: Color = Color.gray
    @State var hasBlur: Bool = true
    @State var changingBlur: Double = 30
    @State var usesStyles: Bool = false
    @State var changingFill: String = ""
    @State var changingStroke: String = ""
    
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
                                    operation = CorruptingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, active: isActive)
                                }
                            }
                            
                            let replacingAction = UIAlertAction(title: NSLocalizedString("Replacing", comment: "operation type that replaces a file"), style: .default) { (action) in
                                // change the type
                                if !(operation is ReplacingObject) {
                                    operation = ReplacingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, active: isActive, overwriteData: Data("#".utf8), replacingType: ReplacingObjectType.Imported, replacingPath: "/Unknown")
                                } else {
                                    operation.isCreating = false
                                }
                            }
                            
                            let creatingAction = UIAlertAction(title: NSLocalizedString("Creating", comment: "operation type that creates a new file"), style: .default) { (action) in
                                // change the type
                                if !(operation is ReplacingObject) {
                                    operation = ReplacingObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, creating: true, active: isActive, overwriteData: Data("#".utf8), replacingType: ReplacingObjectType.Imported, replacingPath: "/Unknown")
                                } else {
                                    operation.isCreating = true
                                }
                            }
                            
                            let plistAction = UIAlertAction(title: NSLocalizedString("Plist", comment: "operation type that changes plist keys"), style: .default) { (action) in
                                // change the type
                                if !(operation is PlistObject) {
                                    operation = PlistObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, active: isActive, plistType: plistType, replacingKeys: replacingKeys)
                                }
                            }
                            
                            let colorAction = UIAlertAction(title: NSLocalizedString("Color", comment: "operation type that changes colors"), style: .default) { (action) in
                                // change the type
                                if !(operation is ColorObject) {
                                    operation = ColorObject(operationName: operationName, filePath: filePath, applyInBackground: applyInBackground, active: isActive)
                                }
                            }
                            
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                // cancels the action
                            }
                            
                            // add the actions
                            alert.addAction(corruptingAction)
                            alert.addAction(replacingAction)
                            alert.addAction(creatingAction)
                            if #available(iOS 15, *) {
                                alert.addAction(plistAction)
                            }
                            alert.addAction(colorAction)
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
                            } else if operation is ReplacingObject && !operation.isCreating {
                                Text("Replacing")
                                    .foregroundColor(.blue)
                            } else if operation is ReplacingObject && operation.isCreating {
                                Text("Creating")
                                    .foregroundColor(.blue)
                            } else if operation is PlistObject {
                                Text("Plist")
                                    .foregroundColor(.blue)
                            } else if operation is ColorObject {
                                Text("Color")
                                    .foregroundColor(.blue)
                            } else {
                                Text("????")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // MARK: Enabled
                    HStack {
                        Text("Enabled")
                            .bold()
                        Spacer()
                        Toggle(isOn: $isActive) {}
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
                            if operation.isCreating {
                                if FileManager.default.isWritableFile(atPath: filePath) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                        .padding(.bottom, 10)
                                } else {
                                    Text("Cannot write to file path!")
                                        .multilineTextAlignment(.trailing)
                                        .padding(.bottom, 10)
                                }
                            } else {
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
                                            savedFilePath = tmp
                                            
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
                                        TextField("Path", text: $replacingPath)
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
                                if !operation.isCreating {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        if FileManager.default.fileExists(atPath: replacingPath), let fileData = try? Data(contentsOf: URL(fileURLWithPath: replacingPath)) {
                                            Text("\(fileData.count) bytes")
                                                .multilineTextAlignment(.trailing)
                                                .padding(.bottom, 10)
                                            if FileManager.default.isWritableFile(atPath: filePath) {
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(.green)
                                            } else {
                                                if FileManager.default.fileExists(atPath: filePath), let fileData2 = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                                                    if fileData2.count >= fileData.count {
                                                        Image(systemName: "checkmark.circle")
                                                            .foregroundColor(.green)
                                                    } else {
                                                        Image(systemName: "x.circle")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("File not found!")
                                                .multilineTextAlignment(.trailing)
                                                .padding(.bottom, 10)
                                        }
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
                                if !operation.isCreating {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        if replacingData != nil {
                                            Text("\(replacingData!.count) bytes")
                                                .multilineTextAlignment(.trailing)
                                                .padding(.bottom, 10)
                                            if FileManager.default.isWritableFile(atPath: filePath) {
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(.green)
                                            } else {
                                                if FileManager.default.fileExists(atPath: filePath), let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                                                    if fileData.count >= replacingData!.count {
                                                        Image(systemName: "checkmark.circle")
                                                            .foregroundColor(.green)
                                                    } else {
                                                        Image(systemName: "x.circle")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("File not found!")
                                                .multilineTextAlignment(.trailing)
                                                .padding(.bottom, 10)
                                        }
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
                            
                            if showPaddingButton == true, let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        UIApplication.shared.alert(title: NSLocalizedString("Generating padding...", comment: "Custom operation generating plist padding"), body: NSLocalizedString("Please wait...", comment: ""), animated: true, withButton: false)
                                        do {
                                            let plist = try PropertyListSerialization.propertyList(from: replacingData!, options: [], format: nil) as! [String: Any]
                                            let newData = try addEmptyData(matchingSize: fileData.count, to: plist)
                                            replacingData = newData
                                            showPaddingButton = false
                                            UIApplication.shared.dismissAlert(animated: true)
                                        } catch {
                                            UIApplication.shared.dismissAlert(animated: true)
                                            UIApplication.shared.alert(body: error.localizedDescription)
                                        }
                                    }) {
                                        Text("Generate Padding")
                                            .foregroundColor(.blue)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(operation.isCreating ? "Creating Data" : "Replacement Data")
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
                                if FileManager.default.isWritableFile(atPath: filePath) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                } else {
                                    if FileManager.default.fileExists(atPath: filePath), let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                                        if fileData.count >= calculatedSize! {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "x.circle")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
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
                                        if !(plist.value.wrappedValue is String && (plist.value.wrappedValue as! String) == ".Cowabunga-DELETIGN") {
                                            Text(String(describing: plist.value.wrappedValue))
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Deleting")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { i in
                                    let deletingProperty = plistKeys[i].key
                                    replacingKeys.removeValue(forKey: deletingProperty)
                                    plistKeys.remove(at: i)
                                }
                            }
                        }
                    } header: {
                        Text("Plist Data")
                    }
                }
                
                // MARK: Color Object Operation
                if operation is ColorObject {
                    Section {
                        // MARK: Color Picker
                        HStack {
                            Text("Color")
                                .bold()
                            Spacer()
                            ColorPicker("Set color", selection: $changingColor)
                                .labelsHidden()
                        }
                        
                        // MARK: Blur Slider
                        HStack {
                            Text("Blur Enabled")
                                .bold()
                            Spacer()
                            Toggle(isOn: $hasBlur) {}
                        }
                        
                        if hasBlur {
                            HStack {
                                Text("Blur:   \(Int(changingBlur))")
                                    .foregroundColor(.white)
                                    .frame(width: 125)
                                Spacer()
                                Slider(value: $changingBlur, in: 0...150, step: 1.0)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // MARK: Using Styles
                        HStack {
                            Text("Uses Styles")
                                .bold()
                            Spacer()
                            Toggle(isOn: $usesStyles) {}
                        }
                        
                        // MARK: Styles
                        if usesStyles {
                            // Fill
                            HStack {
                                Text("Fill Name:")
                                    .bold()
                                Spacer()
                                if #available(iOS 15.0, *) {
                                    TextField("Fill", text: $changingFill)
                                        .multilineTextAlignment(.trailing)
                                        .submitLabel(.done)
                                        .frame(maxHeight: 180)
                                } else {
                                    // Fallback on earlier versions
                                    TextEditor(text: $changingFill)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxHeight: 180)
                                }
                            }
                            
                            // Stroke
                            HStack {
                                Text("Stroke Name:")
                                    .bold()
                                Spacer()
                                if #available(iOS 15.0, *) {
                                    TextField("Stroke", text: $changingStroke)
                                        .multilineTextAlignment(.trailing)
                                        .submitLabel(.done)
                                        .frame(maxHeight: 180)
                                } else {
                                    // Fallback on earlier versions
                                    TextEditor(text: $changingStroke)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxHeight: 180)
                                }
                            }
                        }
                        
                        // MARK: Auto Detect Styles
                        HStack {
                            Spacer()
                            Button(action: {
                                if let colorOperation = operation as? ColorObject {
                                    do {
                                        let styles = try colorOperation.detectStyles()
                                        if styles["fill"] == nil && styles["stroke"] == nil {
                                            // no styles found
                                            usesStyles = false
                                        } else {
                                            usesStyles = true
                                            changingFill = styles["fill"] ?? ""
                                            changingStroke = styles["stroke"] ?? ""
                                        }
                                    } catch {
                                        UIApplication.shared.alert(title: NSLocalizedString("Could not detect styles.", comment: "when color styles could not be determined"), body: error.localizedDescription)
                                    }
                                }
                            }) {
                                Text("Determine Styles")
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.blue)
                            }
                        }
                    } header: {
                        Text("Color Data")
                    }
                }
                
                // MARK: Operation Actions
                Section {
                    VStack {
                        // MARK: Save
                        Button(action: {
                            saveCurrentOperation()
                        }) {
                            if editing {
                                Text("Save")
                            } else {
                                Text("Create")
                            }
                        }
                        .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                        
                        // MARK: Apply Once
                        Button("Apply Without Saving") {
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
                        .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                        if editing {
                            // MARK: Delete
                            Button(action: {
                                // restore the data
                                UIApplication.shared.alert(title: NSLocalizedString("Restoring original file...", comment: "restore button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
                                do {
                                    try operation.applyData(fromBackup: true)
                                } catch {
                                    print(error.localizedDescription)
                                }
                                // apply the changes
                                UIApplication.shared.change(title: NSLocalizedString("Deleting operation...", comment: "delete button on custom operations"), body: NSLocalizedString("Please wait", comment: ""))
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
                            .buttonStyle(TintedButton(color: .red, fullwidth: true))
                            
                            // MARK: Restore
                            if !operation.isCreating {
                                Button(action: {
                                    // apply the changes
                                    UIApplication.shared.alert(title: NSLocalizedString("Restoring original file...", comment: "restore button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
                                    do {
                                        try operation.applyData(fromBackup: true)
                                        UIApplication.shared.dismissAlert(animated: true)
                                        UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The file was successfully restored!", comment: "when an operation is restored"))
                                    } catch {
                                        UIApplication.shared.dismissAlert(animated: true)
                                        UIApplication.shared.alert(body: NSLocalizedString("An error occurred while restoring the files", comment: "when an operation fails to restore") + ": \(error.localizedDescription)")
                                    }
                                }) {
                                    Text("Restore")
                                }
                                .buttonStyle(TintedButton(color: .green, fullwidth: true))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
            }
            .toolbar {
                if editing {
                    // create export button
                    Button(action: {
                        // get the saved author name if it exists
                        let savedAuthorName = UserDefaults.standard.string(forKey: "CustomOperationsAuthorName")
                        if savedAuthorName == nil {
                            // user did not set an author name
                            // create and configure alert controller
                            let alert = UIAlertController(title: NSLocalizedString("Author Name", comment: "Header for inputting your name"), message: NSLocalizedString("Enter your name and you will be credited for creating the operation.", comment: "Message for inputting your name in custom operation"), preferredStyle: .alert)
                            // bring up the text prompt
                            alert.addTextField { (textField) in
                                textField.placeholder = "Enter Name"
                            }
                            
                            // buttons
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Apply", comment: ""), style: .default) { (action) in
                                // set the version
                                let author: String = alert.textFields?[0].text ?? ""
                                saveCurrentOperation(author, alerts: false)
                                do {
                                    let archiveURL = try AdvancedManager.exportOperation(operationName)
                                    
                                    // show share menu
                                    let avc = UIActivityViewController(activityItems: [archiveURL], applicationActivities: nil)
                                    let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                                    avc.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                                    avc.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                                    UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
                                } catch {
                                    UIApplication.shared.alert(title: NSLocalizedString("Operation export failed!", comment: "failing to export custom operation"), body: error.localizedDescription)
                                }
                            })
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                // cancel the process
                            })
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                        } else {
                            saveCurrentOperation(savedAuthorName!, alerts: false)
                            do {
                                let archiveURL = try AdvancedManager.exportOperation(operationName)
                                
                                // show share menu
                                let avc = UIActivityViewController(activityItems: [archiveURL], applicationActivities: nil)
                                let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                                avc.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                                avc.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                                UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
                            } catch {
                                UIApplication.shared.alert(title: NSLocalizedString("Operation export failed!", comment: "failing to export custom operation"), body: error.localizedDescription)
                            }
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $isImporting) {
                DocumentPicker(types: [.data]) { result in
                    if result.first == nil { UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of file. Did you select it?", comment: "")); return }
                    let url: URL = result.first!
                    guard url.startAccessingSecurityScopedResource() else { UIApplication.shared.alert(body: "File permission error"); return }
                    
                    // save to temp directory
                    do {
                        let tmp = FileManager.default.temporaryDirectory
                        replacingData = try Data(contentsOf: url)
                        let newURL = tmp.appendingPathComponent(url.lastPathComponent)
                        // write to temp file
                        try replacingData!.write(to: newURL)
                        replacingPath = newURL.path
                        showPaddingButton = hasPadding.contains(URL(fileURLWithPath: replacingPath).pathExtension)
                        url.stopAccessingSecurityScopedResource()
                    } catch {
                        UIApplication.shared.alert(body: NSLocalizedString("An error occurred", comment: "") + ": \(error.localizedDescription)")
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            }
            .navigationTitle(pageTitle)
            .onAppear {
                pageTitle = editing ? NSLocalizedString("Edit Operation", comment: "") : NSLocalizedString("Create Operation", comment: "")
                
                if replacingKeys.count == 0 {
                    isActive = operation.isActive
                    previousFilePath = operation.filePath
                    operationName = operation.operationName
                    previousName = operationName
                    filePath = operation.filePath
                    applyInBackground = operation.applyInBackground
                }
                
                if let replacingOperation = operation as? ReplacingObject {
                    replacingType = replacingOperation.replacingType
                    replacingPath = replacingOperation.replacingPath
                    if replacingOperation.replacingType == .Imported && operation.replacementData != Data("#".utf8) {
                        replacingData = operation.replacementData
                        showPaddingButton = hasPadding.contains(URL(fileURLWithPath: replacingPath).pathExtension)
                    }
                } else if let plistOperation = operation as? PlistObject {
                    plistType = plistOperation.plistType
                    if replacingKeys.count == 0 {
                        // populate plist
                        replacingKeys = plistOperation.replacingKeys
                        for (k, v) in replacingKeys {
                            plistKeys.append(.init(key: k, oldKey: k, value: v))
                        }
                    }
                } else if let colorOperation = operation as? ColorObject {
                    changingColor = colorOperation.col
                    if colorOperation.blur == -1 {
                        hasBlur = false
                    } else {
                        changingBlur = colorOperation.blur
                    }
                    
                    usesStyles = colorOperation.usesStyles
                    changingFill = colorOperation.fill
                    changingStroke = colorOperation.stroke
                }
                
                replacingKeys.removeAll(keepingCapacity: true)
                
                for (_, plist) in plistKeys.enumerated() {
                    replacingKeys[plist.key] = plist.value
                }
            }
        }
    }
    
    func applyOperationProperties(_ author: String = "") {
        // set the properties of the operation
        operation.operationName = operationName
        operation.filePath = filePath
        operation.applyInBackground = applyInBackground
        operation.isActive = isActive
        if author != "" {
            operation.author = author
        }
        if operation is ReplacingObject, let operation = operation as? ReplacingObject {
            operation.replacingType = replacingType
            operation.replacingPath = replacingPath
        } else if operation is PlistObject, let operation = operation as? PlistObject {
            operation.replacingKeys = replacingKeys
            operation.plistType = plistType
        } else if operation is ColorObject, let operation = operation as? ColorObject {
            operation.col = changingColor
            if !hasBlur {
                operation.blur = -1
            } else {
                operation.blur = changingBlur
            }
            
            operation.usesStyles = usesStyles
            operation.fill = changingFill
            operation.stroke = changingStroke
        }
    }
    
    func saveCurrentOperation(_ author: String = "", alerts: Bool = true) {
        // apply the changes
        if alerts {
            UIApplication.shared.alert(title: NSLocalizedString("Saving operation...", comment: "apply button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
        }
        if operation is ReplacingObject && replacingType == .Imported && replacingData == nil {
            UIApplication.shared.alert(body: NSLocalizedString("Please select a file to import!", comment: ""))
        } else {
            applyOperationProperties(author)
            do {
                if isActive {
                    do {
                        try operation.parseData()
                        try operation.applyData()
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    do {
                        try operation.applyData(fromBackup: true)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if !editing || previousFilePath != filePath {
                    try operation.backup()
                }
                try AdvancedManager.deleteOperation(operationName: previousName)
                try AdvancedManager.saveOperation(operation: operation, category: category, replacingFileData: replacingData)
                UIApplication.shared.dismissAlert(animated: true)
                if alerts {
                    UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully saved!", comment: "when an operation is saved"))
                }
            } catch {
                UIApplication.shared.dismissAlert(animated: true)
                UIApplication.shared.alert(body: NSLocalizedString("An error occurred while saving the operation", comment: "when an operation fails to save") + ": \(error.localizedDescription)")
            }
        }
    }
}
