//
//  OperationPlistEditView.swift
//  Cowabunga
//
//  Created by lemin on 2/10/23.
//

import SwiftUI

@available(iOS 15.0, *)
struct PlistEditView: View {
    @Binding var plistKey: String
    @Binding var plistValue: Any
    
    @State var textFieldRawText: String = ""
    @State var textFieldRawInt: Int = 0
    @State var textFieldRawDouble: Double = 0
    @State var textFieldRawBool: Bool = false
    
    var body: some View {
        VStack {
            List {
                // MARK: Value Type
                Button(action: {
                    // create and configure alert controller
                    let alert = UIAlertController(title: NSLocalizedString("Choose a value type", comment: ""), message: "", preferredStyle: .actionSheet)
                    
                    // create the actions
                    let strAction = UIAlertAction(title: "String", style: .default) { (action) in
                        plistValue = textFieldRawText
                    }
                    let intAction = UIAlertAction(title: "Int", style: .default) { (action) in
                        plistValue = textFieldRawInt
                    }
                    let doubleAction = UIAlertAction(title: "Double", style: .default) { (action) in
                        plistValue = textFieldRawDouble
                    }
                    let boolAction = UIAlertAction(title: "Boolean", style: .default) { (action) in
                        plistValue = textFieldRawBool
                    }
                    let deleteAction = UIAlertAction(title: "Deleting", style: .destructive) { (action) in
                        plistValue = ".Cowabunga-DELETIGN"
                    }
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                        // cancels the action
                    }
                    
                    // add the actions
                    alert.addAction(strAction)
                    alert.addAction(intAction)
                    alert.addAction(doubleAction)
                    alert.addAction(boolAction)
                    alert.addAction(deleteAction)
                    
                    alert.addAction(cancelAction)
                    
                    let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                    // present popover for iPads
                    alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                    alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                    
                    // present the alert
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }) {
                    if !(plistValue is String && (plistValue as! String) == ".Cowabunga-DELETIGN") {
                        Text(String(describing: type(of: plistValue)))
                            .foregroundColor(.blue)
                    } else {
                        Text("Deleting")
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: Key Name
                HStack {
                    Text(NSLocalizedString("Key", comment: "key for plist operation"))
                        .bold()
                    Spacer()
                    TextField(NSLocalizedString("Key", comment: "key for plist operation"), text: $plistKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // MARK: Value
                HStack {
                    Text(NSLocalizedString("Value", comment: "value for plist operation"))
                        .bold()
                    Spacer()
                    
                    if plistValue is String {
                        if (plistValue as! String) != ".Cowabunga-DELETIGN" {
                            // For strings
                            TextField(NSLocalizedString("Value", comment: "value for plist operation"), text: $textFieldRawText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .submitLabel(.done)
                                .onSubmit {
                                    plistValue = textFieldRawText
                                }
                        }
                    } else if plistValue is Int {
                        // For ints
                        TextField(NSLocalizedString("Value", comment: "value for plist operation"), value: $textFieldRawInt, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                plistValue = textFieldRawInt
                            }
                    } else if plistValue is Double {
                        // For doubles
                        TextField(NSLocalizedString("Value", comment: "value for plist operation"), value: $textFieldRawDouble, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                plistValue = textFieldRawDouble
                            }
                    } else if plistValue is Bool {
                        // For bools
                        Toggle(isOn: $textFieldRawBool) {
                            Text("")
                        }
                        .labelsHidden()
                        .onChange(of: textFieldRawBool, perform: { (value) in
                            plistValue = value
                        })
                    }
                }
            }
        }
        .navigationTitle("Editing \(plistKey)")
        .onAppear {
            if plistValue is String {
                textFieldRawText = plistValue as! String
            } else if plistValue is Int {
                textFieldRawInt = plistValue as! Int
            } else if plistValue is Double {
                textFieldRawDouble = plistValue as! Double
            } else if plistValue is Bool {
                textFieldRawBool = plistValue as! Bool
            }
        }
    }
}
