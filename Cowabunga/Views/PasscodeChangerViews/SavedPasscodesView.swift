//
//  SavedPasscodesView.swift
//  Cowabunga
//
//  Created by lemin on 1/30/23.
//

import SwiftUI

struct SavedPasscodesView: View {
    @State private var savedPasscodesDir = PasscodeKeyFaceManager.getPasscodesDirectory()
    @State private var numOfSaved = 0
    
    var body: some View {
        VStack {
            if numOfSaved == 0 {
                Text("You do not have any saved passcode themes. Check out the explore tab to find some!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    HStack {
                        Image(systemName: "phone")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 40, maxHeight: 40)
                            .cornerRadius(10, corners: .topLeft)
                            .cornerRadius(10, corners: .topRight)
                        
                        Text("Passcode Name Here")
                            .minimumScaleFactor(0.5)
                            .font(.system(size: 24, weight: .bold))
                    }
                }
            }
        }
        .onAppear {
            do {
                if savedPasscodesDir != nil {
                    numOfSaved = try FileManager.default.contentsOfDirectory(at: savedPasscodesDir!, includingPropertiesForKeys: nil).count
                }
            } catch {
                print("Error getting contents of directory")
            }
        }
    }
}

struct SavedPasscodesView_Previews: PreviewProvider {
    static var previews: some View {
        SavedPasscodesView()
    }
}
