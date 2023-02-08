//
//  AdvancedView.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import SwiftUI

struct AdvancedView: View {
    @State private var operations: [AdvancedCategory] = [
        .init(categoryName: "", categoryOperations: [
            CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false)
        ]),
        .init(categoryName: "Test Category", categoryOperations: [
            ReplacingObject(operationName: "Replace Egg", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: true, overwriteData: Data("#".utf8))
        ])
    ]
    /*@State private var operations: [AdvancedObject] = [
        CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false),
        ReplacingObject(operationName: "Replace Egg", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: true, overwriteData: Data("#".utf8))
    ]*/
    
    // lazyvgrid
    
    var body: some View {
        VStack {
            List {
                ForEach($operations) { cat in
                    Section {
                        ForEach(cat.categoryOperations) { operation in
                            NavigationLink(destination: EditingOperationView(operation: operation.wrappedValue)) {
                                HStack {
                                    Text(operation.operationName.wrappedValue)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                    } header: {
                        Text(cat.categoryName.wrappedValue)
                    }
                }
            }
            .navigationTitle("Custom Operations")
        }
    }
}

struct AdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedView()
    }
}
