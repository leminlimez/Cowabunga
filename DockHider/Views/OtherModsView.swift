//
//  OtherModsView.swift
//  DockHider
//
//  Created by lemin on 1/6/23.
//

import SwiftUI

struct OtherModsView: View {
    var body: some View {
        VStack {
            // title
            Text("Cowabunga")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            Text("Miscelaneous Modifications")
                .font(.title2)
                .padding(.bottom, 10)
        }
    }
}

struct OtherModsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherModsView()
    }
}
