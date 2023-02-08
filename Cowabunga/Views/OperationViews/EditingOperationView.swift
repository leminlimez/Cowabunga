//
//  EditingOperationView.swift
//  Cowabunga
//
//  Created by lemin on 2/8/23.
//

import SwiftUI

struct EditingOperationView: View {
    var operation: AdvancedObject
    
    var body: some View {
        VStack {
            List {
                Section {
                    // MARK: Operation Name
                    HStack {
                        Text("Name:")
                            .bold()
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Text(operation.operationName)
                                .foregroundColor(.blue)
                        }
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
            }
            .navigationTitle("Edit Operation")
        }
    }
}

struct EditingOperationView_Previews: PreviewProvider {
    static var previews: some View {
        EditingOperationView(operation: CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false))
    }
}
