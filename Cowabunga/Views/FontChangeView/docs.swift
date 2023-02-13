////
////  docs.swift
////  TrollBox
////
////  Created by Constantin Clerc on 03/01/2023.
////
//
//import SwiftUI
//import UniformTypeIdentifiers
//
//class WDBImportCustomFontPickerViewControllerDelegate: NSObject, UIDocumentPickerDelegate {
//    let name: String
//    let ttcRepackMode: TTCRepackMode
//    let completion: (String) -> Void
//
//    init(name: String, ttcRepackMode: TTCRepackMode, completion: @escaping (String) -> Void) {
//        self.name = name
//        self.ttcRepackMode = ttcRepackMode
//        self.completion = completion
//    }
//
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard urls.count == 1 else {
//            completion("import one file at a time")
//            return
//        }
//
//        Task(priority: .background) {
//            let fileURL = urls[0]
//            let documentDirectory = FileManager.default.urls(
//                for: .documentDirectory,
//                in: .userDomainMask
//            )[0]
//            let targetURL = documentDirectory.appendingPathComponent(self.name)
//            let success = importCustomFontImpl(
//                fileURL: fileURL,
//                targetURL: targetURL,
//                ttcRepackMode: self.ttcRepackMode
//            )
//            await MainActor.run { [weak self] in
//                self?.completion(success ?? "Imported")
//            }
//        }
//    }
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        completion("Cancelled")
//    }
//}
//
//// https://capps.tech/blog/read-files-with-documentpicker-in-swiftui
//struct WDBDocumentPicker: UIViewControllerRepresentable {
//    var name: String
//    var ttcRepackMode: TTCRepackMode
//    var completion: (String) -> Void
//
//    func makeCoordinator() -> WDBImportCustomFontPickerViewControllerDelegate {
//        return WDBImportCustomFontPickerViewControllerDelegate(
//            name: name,
//            ttcRepackMode: ttcRepackMode,
//            completion: completion
//        )
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<WDBDocumentPicker>) -> UIDocumentPickerViewController {
//        print("make ui view controller?")
//
//        let pickerViewController = UIDocumentPickerViewController(
//            forOpeningContentTypes: [
//                UTType.font,
//                UTType(
//                    filenameExtension: "woff2",
//                    conformingTo: .font
//                )!,
//            ],
//            asCopy: true
//        )
//
//        pickerViewController.delegate = context.coordinator
//        return pickerViewController
//    }
//
//    func updateUIViewController(
//        _ uiViewController: UIDocumentPickerViewController,
//        context: UIViewControllerRepresentableContext<WDBDocumentPicker>
//    ) {}
//}
