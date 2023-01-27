//
//  LockView.swift
//  Cowabunga
//
//  Created by lemin on 1/27/23.
//
// Credit to Haxi0 for original TrollLock

import Foundation
import SwiftUI

struct LockView: View {
    var body: some View {
        VStack {
            Button(action: {
                print("applying lock")
                LockManager.applyLock(sourceURL: LockManager.getLockFolder(lockName: "Troll")!, lockType: "3x-812h")
            }) {
                Text("Test")
            }
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
    }
}
