//
//  AdvancedView.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import SwiftUI

struct AdvancedView: View {
    @State private var operations: [AdvancedObject] = [
        CorruptingObject.init(operationName: "Test Operation", filePath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/podBackgroundViewLight.visualstyleset", singleApply: false, applyInBackground: false)
    ]
    
    // lazyvgrid
    private var gridItemLayout = [GridItem(.adaptive(minimum: 200))]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(operations) { operation in
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.4))
                                .cornerRadius(10)
                            
                            VStack {
                                // title
                                HStack {
                                    Text(operation.operationName)
                                        .padding(5)
                                        .font(.system(size: 22, weight: .heavy))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    // edit button
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                            .font(.system(size: 25))
                                    }
                                    .padding(5)
                                }
                                
                                // type of operation
                                HStack {
                                    Text("Type:")
                                        .font(.system(size: 14, weight: .heavy))
                                        .padding(.leading, 10)
                                        .padding(.bottom, 5)
                                    Spacer()
                                    if operation is CorruptingObject {
                                        Text("Corrupting")
                                            .padding(.bottom, 5)
                                            .padding(.trailing, 10)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                
                                // uses background services
                                HStack {
                                    Text("Apply in Background:")
                                        .font(.system(size: 14, weight: .heavy))
                                        .padding(.leading, 10)
                                        .padding(.bottom, 5)
                                    
                                    Spacer()
                                    
                                    if operation.applyInBackground == true {
                                        Text("Yes")
                                            .font(.system(size: 14, weight: .bold))
                                            .padding(.trailing, 10)
                                            .padding(.bottom, 5)
                                            .foregroundColor(.green)
                                    } else {
                                        Text("No")
                                            .font(.system(size: 14, weight: .bold))
                                            .padding(.trailing, 10)
                                            .padding(.bottom, 5)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                // path
                                HStack {
                                    Text("Path:")
                                        .font(.system(size: 14, weight: .heavy))
                                        .padding(.leading, 10)
                                        .padding(.bottom, 5)
                                    
                                    Spacer()
                                    
                                    Text(operation.filePath)
                                        .font(.system(size: 14))
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 5)
                                }
                            }
                            .padding(10)
                        }
                        .padding(12)
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
