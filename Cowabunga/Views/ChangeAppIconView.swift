//
//  ChangeAppIconView.swift
//  Cowabunga
//
//  Created by lemin on 2/16/23.
//

import SwiftUI

struct ChangeAppIconView: View {
    @StateObject var viewModel = ChangeAppIconViewModel()

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 11) {
                    ForEach(ChangeAppIconViewModel.AppIcon.allCases) { appIcon in
                        HStack(spacing: 16) {
                            Image(uiImage: appIcon.preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            if appIcon.author == "" {
                                Text(appIcon.description)
                                    .bold()
                            } else {
                                VStack (alignment: .leading) {
                                    Text(appIcon.description)
                                        .bold()
                                        .padding(.bottom, 2)
                                    Text(appIcon.author)
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(viewModel.selectedAppIcon == appIcon ? 1 : 0)
                                .padding(10)
                                .font(.system(size: 20))
                        }
                        .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
                        .background(Color(uiColor14: .secondarySystemBackground))
                        .cornerRadius(20)
                        .onTapGesture {
                            withAnimation {
                                viewModel.updateAppIcon(to: appIcon)
                            }
                        }
                    }
                }.padding(.horizontal)
                    .padding(.vertical, 40)
            }
        }
        .navigationTitle("Choose app Icon")
    }
}

struct ChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppIconView()
    }
}
