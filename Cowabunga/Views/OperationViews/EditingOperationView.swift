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
                    HStack {
                        Text("Path:")
                            .bold()
                        Spacer()
                        TextField("File Path", text: $filePath)
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
                
                Section {
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
            }
            .navigationTitle("Edit Operation")
            .onAppear {
                operationName = operation.operationName
                filePath = operation.filePath
                applyInBackground = operation.applyInBackground
            }
        }
    }
}

struct EditingOperationView_Previews: PreviewProvider {
    static var previews: some View {
        EditingOperationView(operation: CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false))
    }
}
