//
//  EditingOperationView.swift
//  Cowabunga
//
//  Created by lemin on 2/8/23.
//

import SwiftUI

struct EditingOperationView: View {
    var operation: AdvancedObject
    
    @State var operationName: String = ""
    @State var filePath: String = ""
    @State var applyInBackground: Bool = false
    
    @State var replacingType: ReplacingObjectType? = nil
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
                                
                            }) {
                                Text(replacingType?.rawValue ?? "Error")
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
                        }
                        .buttonStyle(FullwidthTintedButton(color: .blue))
                        
                        // MARK: Delete
                        Button("Delete") {
                            // delete the
                        }
                        .buttonStyle(FullwidthTintedButton(color: .red))
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

struct EditingOperationView_Previews: PreviewProvider {
    static var previews: some View {
        EditingOperationView(operation: CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false))
    }
}
