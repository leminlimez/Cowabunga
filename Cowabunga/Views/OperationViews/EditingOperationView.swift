//
//  EditingOperationView.swift
//  Cowabunga
//
//  Created by lemin on 2/8/23.
//

import SwiftUI

struct EditingOperationView: View {
    var category: String
    @State var operation: AdvancedObject
    
    @State var operationName: String = ""
    @State var filePath: String = ""
    @State var applyInBackground: Bool = false
    
    @State var replacingType: ReplacingObjectType = ReplacingObjectType.Imported
    @State var replacingPath: String = ""
    
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
                                    operation = CorruptingObject(operationName: operationName, filePath: filePath, singleApply: false, applyInBackground: applyInBackground)
                                }
                            }
                            
                            let replacingAction = UIAlertAction(title: NSLocalizedString("Replacing", comment: "operation type that replaces a file"), style: .default) { (action) in
                                // change the type
                                if !(operation is ReplacingObject) {
                                    operation = ReplacingObject(operationName: operationName, filePath: filePath, singleApply: false, applyInBackground: applyInBackground, overwriteData: Data("#".utf8), replacingType: ReplacingObjectType.Imported, replacingPath: "/Unknown")
                                }
                            }
                            
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                                // cancels the action
                            }
                            
                            // add the actions
                            alert.addAction(corruptingAction)
                            alert.addAction(replacingAction)
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
                
                Section {
                    VStack {
                        // MARK: Save
                        Button("Apply") {
                            // apply the changes
                            UIApplication.shared.alert(title: NSLocalizedString("Saving operation...", comment: "apply button on custom operations"), body: NSLocalizedString("Please wait", comment: ""), animated: false, withButton: false)
                            // set the properties of the operation
                            operation.operationName = operationName
                            operation.filePath = filePath
                            operation.applyInBackground = applyInBackground
                            if operation is ReplacingObject, var operation = operation as? ReplacingObject {
                                operation.replacingType = replacingType
                                operation.replacingPath = replacingPath
                            }
                            do {
                                try AdvancedManager.saveOperation(operation: operation, category: category)
                                UIApplication.shared.dismissAlert(animated: true)
                                UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The operation was successfully saved!", comment: "when an operation is saved"))
                            } catch {
                                UIApplication.shared.dismissAlert(animated: true)
                                UIApplication.shared.alert(body: NSLocalizedString("An error occurred while saving the operation", comment: "when an operation fails to apply") + ": \(error.localizedDescription)")
                            }
                        }
                        .buttonStyle(FullwidthTintedButton(color: .blue))
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
        }
    }
}
