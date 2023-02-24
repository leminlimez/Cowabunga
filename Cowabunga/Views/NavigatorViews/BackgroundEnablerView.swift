//
//  BackgroundEnablerView.swift
//  Cowabunga
//
//  Created by lemin on 2/24/23.
//

import SwiftUI

struct BackgroundEnablerView: View {
    @Binding var isVisible: Bool
    @State var bgOptions: [BackgroundOption] = BackgroundFileUpdaterController.shared.BackgroundOptions
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack (alignment: .leading) {
                        Text("Background Services")
                            .font(.title)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 5)
                        Text("Toggle what services will run or apply when the app is in the background.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Section {
                    ForEach($bgOptions) { bgOption in
                        Toggle(isOn: bgOption.enabled) {
                            Text(bgOption.title.wrappedValue)
                        }.onChange(of: bgOption.enabled.wrappedValue) { new in
                            UserDefaults.standard.set(new, forKey: bgOption.key.wrappedValue + "_BGApply")
                        }
                    }
                }
            }
        }
    }
}
