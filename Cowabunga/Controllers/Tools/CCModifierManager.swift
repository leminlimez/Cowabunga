//
//  CCModifierManager.swift
//  Cowabunga
//
//  Created by lemin on 2/28/23.
//

import Foundation

// MARK: Module Types
enum ModuleType {
    case regular
    case slider
    case quick
    case music
    case focus
    case invis
}

// MARK: Module Class
class CCModule: Identifiable {
    var width: Int
    var height: Int
    var type: ModuleType
    var icon: String
    
    // constructor for regular module
    init(width: Int, height: Int, type: ModuleType, icon: String) {
        self.width = width
        self.height = height
        self.type = type
        self.icon = icon
    }
    
    // constructor for regular module without size
    init(icon: String) {
        self.width = 1
        self.height = 1
        self.type = .regular
        self.icon = icon
    }
    
    // constructor for module without regular icon
    init(width: Int, height: Int, type: ModuleType) {
        self.width = width
        self.height = height
        self.type = type
        self.icon = ""
    }
    
    // constructor for invisible module
    init(width: Int) {
        self.width = width
        self.height = 1
        self.type = ModuleType.invis
        self.icon = ""
    }
}

struct CCModuleViewable: Identifiable {
    var id = UUID()
    
    var width: CGFloat
    var height: CGFloat
    var widthVal: Int
    var isInvisible: Bool
    var icon: String
    var type: ModuleType
    var attachmentIndex: Int
}

class CCModifierManager {
    static func getModules() -> [CCModule] {
        return [
            .init(width: 2, height: 2, type: .quick),
            .init(width: 2, height: 2, type: .music),
            .init(icon: "lock.open.rotation"),
            .init(icon: "rectangle.on.rectangle"),
            .init(width: 1, height: 2, type: .slider, icon: "sun.max.fill"),
            .init(width: 1, height: 2, type: .slider, icon: "speaker.wave.3.fill"),
            .init(width: 2, height: 1, type: .focus, icon: "moon.fill"),
            
            .init(icon: "flashlight.off.fill"),
            .init(icon: "bell.fill"),
            .init(icon: "battery.50"),
            .init(icon: "camera.fill")
        ]
    }
}
