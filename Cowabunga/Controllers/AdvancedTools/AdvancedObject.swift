//
//  AdvancedObject.swift
//  Cowabunga
//
//  Created by lemin on 2/7/23.
//

import Foundation

enum AdvancedObjectType {
    case plist
    case bplist
    case other
}

class AdvancedObject {
    let type: AdvancedObjectType
    
    init(type: AdvancedObjectType) {
        self.type = type
    }
}
