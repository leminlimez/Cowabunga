////
////  ContentView.swift
////  HCaptcha_SwiftUI_Example
////
////  Copyright © 2022 HCaptcha. MIT License.
////
//
//import SwiftUI
//import HCaptcha
//
//// Wrapper-view to provide UIView instance
//struct UIViewWrapperView: UIViewRepresentable {
//    var uiview = UIView()
//    
//    func makeUIView(context: Context) -> UIView {
//        uiview.backgroundColor = .gray
//        return uiview
//    }
//    
//    func updateUIView(_ view: UIView, context: Context) {
//        // nothing to update
//    }
//}
//
//// Example of hCaptcha usage
//struct HCaptchaView: View {
//    private(set) var hcaptcha: HCaptcha = try! HCaptcha()
//    
//    let placeholder = UIViewWrapperView()
//    
//    var onSuccess: (String) -> ()
//    
//    var body: some View {
//        VStack{
//            placeholder.frame(width: 640, height: 640, alignment: .center)
//            Button(
//                "validate",
//                action: { showCaptcha(placeholder.uiview) }
//            ).padding()
//        }
//        .onAppear {
//            let hostView = self.placeholder.uiview
//            hcaptcha.configureWebView { webview in
//                webview.frame = hostView.bounds
//            }
//        }
//    }
//    
//    func showCaptcha(_ view: UIView) {
//        hcaptcha.validate(on: view) { result in
//            print(result)
//            if let token = try? result.dematerialize() {
//                onSuccess(token)
//            }
//        }
//    }
//}
