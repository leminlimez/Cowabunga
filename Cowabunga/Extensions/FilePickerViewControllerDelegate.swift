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
    let completed: CompletionHandler
    
    init(types: [UTType], completed: @escaping CompletionHandler) {
        self.types = types
        self.completed = completed
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.completed(urls)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    public typealias CompletionHandler = (_ urls: [URL]) -> Void
    
    var types: [UTType]
    var completed: CompletionHandler
    
    func makeCoordinator() -> FilePickerViewControllerDelegate {
        return FilePickerViewControllerDelegate(
            types: types,
            completed: completed
        )
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let pickerViewController = UIDocumentPickerViewController(
            forOpeningContentTypes: types,
            asCopy: false
        )
        
        pickerViewController.allowsMultipleSelection = false
        pickerViewController.delegate = context.coordinator
        return pickerViewController
    }
    
    func updateUIViewController(
        _ uiViewController: UIDocumentPickerViewController,
        context: UIViewControllerRepresentableContext<DocumentPicker>
    ) {}
}
