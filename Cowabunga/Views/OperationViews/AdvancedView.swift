//
//  AdvancedView.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import SwiftUI

struct AdvancedView: View {
    @State private var operations: [AdvancedCategory] = []
    /*@State private var operations: [AdvancedObject] = [
        CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false),
        ReplacingObject(operationName: "Replace Egg", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: true, overwriteData: Data("#".utf8))
    ]*/
    
    // lazyvgrid
    
    var body: some View {
        VStack {
            List(operations, children: \.operations) { operation in
                if operation.categoryName != nil {
                    // it is an operation
                    NavigationLink(destination: EditingOperationView(category: operation.categoryName!, editing: true, operation: try! AdvancedManager.getOperationFromName(operationName: operation.name))) {
                        HStack {
                            if !operation.isActive {
                                Image(systemName: "xmark.seal.fill")
                                    .foregroundColor(.red)
                            }
                            Text(operation.name.replacingOccurrences(of: "_", with: " "))
                                .padding(.horizontal, 8)
                        }
                    }
                } else {
                    // it is a category
                    HStack {
                        Text("Uncategorized")//operation.name.replacingOccurrences(of: "_", with: " "))
                            .padding(.horizontal, 8)
                    }
                }
            }
            .onAppear {
                updateCategories()
            }
            .toolbar {
                // create a category
                /*Button(action: {
                    // ask for a name for the category
                    let alert = UIAlertController(title: NSLocalizedString("Enter Name", comment: ""), message: NSLocalizedString("Choose a name for the category", comment: ""), preferredStyle: .alert)
                    
                    // bring up the text prompts
                    alert.addTextField { (textField) in
                        // text field for width
                        textField.placeholder = NSLocalizedString("New Category", comment: "")
                    }
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { (action) in
                        // set the name and add the file
                        if alert.textFields?[0].text != nil {
                            // check if it is a valid name
                            let validChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890.")
                            let catName: String = (alert.textFields?[0].text ?? "Unnamed").filter{validChars.contains($0)}
                            if catName == "" {
                                UIApplication.shared.alert(body: NSLocalizedString("Please enter a valid category name!", comment: "when user enters a category name that cannot be used"))
                            } else {
                                do {
                                    try AdvancedManager.createCategory(folderURL: AdvancedManager.getSavedOperationsDirectory()!, categoryName: catName)
                                    updateCategories()
                                } catch {
                                    UIApplication.shared.alert(title: NSLocalizedString("Failed to create category", comment: "when the category cannot be created"), body: error.localizedDescription)
                                }
                            }
                        } else {
                            print("alert textfield is nil!")
                            UIApplication.shared.alert(body: "Unexpected error with textfield")
                        }
                    })
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                        // cancel the process
                    })
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }) {
                    Image(systemName: "folder")
                }*/
                
                // create a new operation
                NavigationLink(destination: EditingOperationView(category: "None", editing: false, operation: CorruptingObject(operationName: NSLocalizedString("New Operation", comment: ""), filePath: "/var", applyInBackground: false))) {
                    Image(systemName: "plus")
                }
            }
            .navigationTitle("Custom Operations")
        }
    }
    
    func updateCategories() {
        // load the operation categories
        do {
            operations = try AdvancedManager.loadOperations()
        } catch {
            UIApplication.shared.alert(title: NSLocalizedString("Failed to load operations.", comment: ""), body: error.localizedDescription)
        }
    }
}

struct AdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedView()
    }
}
