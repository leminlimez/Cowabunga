//
//  ContentView.swift
//  DirtyJIT
//
//  Created by Анохин Юрий on 03.03.2023.
//

import SwiftUI

@available(iOS 15.0, *)
struct DirtyJITView: View {
    @AppStorage("firstTime") private var firstTime = true
    @State var apps2: [SBApp2] = []
    @State private var searchText = ""
    @State private var presentAlert = false
    
    var body: some View {
        NavigationView {
            AppsView(searchText: $searchText, apps2: apps2)
                .navigationBarTitle("DirtyJIT", displayMode: .inline)
                .toolbar {
                    Button {
                        presentAlert = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    NavigationLink(destination: DirtySettingsView(firstTime: $firstTime)) {
                        Image(systemName: "gear")
                    }
                }
        }
        .sheet(isPresented: $firstTime, content: SetupView.init)
        .onAppear {
            UIApplication.shared.alert(title: "Loading", body: "Please wait...", withButton: false)
            
//            grant_full_disk_access() { error in
//                print(error?.localizedDescription as Any)
//            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIApplication.shared.dismissAlert(animated: false)
                
                do {
                    apps2 = try ApplicationManager2.getApps()
                } catch {
                    UIApplication.shared.alert(title: "Error", body: error.localizedDescription, withButton: true)
                }
            }
        }
        .textFieldAlert(isPresented: $presentAlert) { () -> TextFieldAlert in
            TextFieldAlert(title: "Enter app name", message: "Search for the app you want to find, make sure you spell it right!", text: Binding<String?>($searchText))
        }
    }
}
