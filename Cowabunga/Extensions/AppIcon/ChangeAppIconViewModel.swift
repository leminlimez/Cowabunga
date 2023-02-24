//
//  ChangeAppIconViewModel.swift
//  Cowabunga
//
//  Created by lemin on 2/16/23.
//

import UIKit

final class ChangeAppIconViewModel: ObservableObject {
    enum AppIcon: String, CaseIterable, Identifiable {
        case primary = "AppIcon"
        case ios6 = "AppIcon-iOS6"
        case pixel = "AppIcon-Pixel"
        case minecraft = "AppIcon-Minecraft"
        case cowtools = "AppIcon-CowTools"
        case glitch = "AppIcon-Glitch"
        case vector = "AppIcon-Vector"

        var id: String { rawValue }
        var iconName: String? {
            switch self {
            case .primary:
                /// `nil` is used to reset the app icon back to its primary icon.
                return nil
            default:
                return rawValue
            }
        }

        var description: String {
            switch self {
                case .primary:
                    return NSLocalizedString("Default", comment: "App icon name")
            case .ios6:
                return NSLocalizedString("iOS 6", comment: "App icon name")
            case .pixel:
                return NSLocalizedString("Pixel Art", comment: "App icon name")
            case .minecraft:
                return NSLocalizedString("Minecraft", comment: "App icon name")
            case .cowtools:
                return NSLocalizedString("CowTools", comment: "App icon name")
            case .glitch:
                return NSLocalizedString("Glitch", comment: "App icon name")
            case .vector:
                return NSLocalizedString("Vector", comment: "App icon name - vector graphics")
            }
        }
        
        var author: String {
            switch self {
            case .primary:
                return ""
            case .ios6:
                return "@asev#2089"
            case .pixel:
                return "@AIslayer#7438"
            case .minecraft:
                return "@Kalphalus#5952"
            case .cowtools:
                return "@NoW4U2Kid#9010"
            case .glitch:
                return "@NoW4U2Kid#9010"
            case .vector:
                return "@AIslayer#7438"
            }
        }

        var preview: UIImage {
            UIImage(named: rawValue + "-preview") ?? UIImage()
        }
    }
    
    @Published private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.iconName else {
                /// No need to update since we're already using this icon.
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                /// We're only logging the error here and not actively handling the app icon failure
                /// since it's very unlikely to fail.
                print("Updating icon to \(String(describing: icon.iconName)) failed.")
                print(error.localizedDescription)

                /// Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}
