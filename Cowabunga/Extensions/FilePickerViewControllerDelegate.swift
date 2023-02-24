//
//  FilePickerDelegate.swift
//  Cowabunga
//
//  Created by lemin on 2/12/23.
//

import SwiftUI
import UniformTypeIdentifiers

class FilePickerViewControllerDelegate: NSObject, UIDocumentPickerDelegate {
    public typealias CompletionHandler = (_ urls: [URL]) -> Void
    
    let types: [UTType]
    let allowsMultipleSelection: Bool
    let completed: CompletionHandler
    
    init(types: [UTType], allowsMultipleSelection: Bool, completed: @escaping CompletionHandler) {
        self.types = types
        self.allowsMultipleSelection = allowsMultipleSelection
        self.completed = completed
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.completed(urls)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    public typealias CompletionHandler = (_ urls: [URL]) -> Void
    
    var types: [UTType]
    var allowsMultipleSelection: Bool = false
    var completed: CompletionHandler
    
    func makeCoordinator() -> FilePickerViewControllerDelegate {
        return FilePickerViewControllerDelegate(
            types: types,
            allowsMultipleSelection: allowsMultipleSelection,
            completed: completed
        )
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let pickerViewController = UIDocumentPickerViewController(
            forOpeningContentTypes: types,
            asCopy: false
        )
        
        pickerViewController.allowsMultipleSelection = allowsMultipleSelection
        pickerViewController.delegate = context.coordinator
        return pickerViewController
    }
    
    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: UIViewControllerRepresentableContext<DocumentPicker>
    ) {}
}
