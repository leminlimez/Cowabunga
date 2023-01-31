//
//  BadgeColorChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 16.10.2022.
//

import UIKit
import Dynamic

class BadgeChanger {
    #if targetEnvironment(simulator)
    static let badgeBitmapPath = "/Users/sourcelocation/Downloads/SBIconBadgeView.BadgeBackground:26:26.cpbitmap"
    #else
    static let badgeBitmapPath = "/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground:26:26.cpbitmap"
    #endif
    
    static func change(to color: UIColor, with radius: CGFloat) throws {
        let radius = max(1, radius)
        let badge: UIImage = try UIImage.circle(radius: UIDevice.current.userInterfaceIdiom == .pad ? radius * 2 : radius, color: color)
        try? FileManager.default.removeItem(atPath: badgeBitmapPath)
        
        badge.writeToCPBitmapFile(to: badgeBitmapPath as NSString)
    }
    
    static func change(to image: UIImage) throws {
        let size = CGSize(width: 26, height: 26)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        try? FileManager.default.removeItem(atPath: badgeBitmapPath)

        resizedImage.writeToCPBitmapFile(to: badgeBitmapPath as NSString)
    }
}

extension UIImage {
    func writeToCPBitmapFile(to path: NSString) {
        Dynamic(self).writeToCPBitmapFile(path, flags: 1)
    }
    
    static func circle(radius: CGFloat, color: UIColor) throws -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: radius, height: radius), false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { throw "Unable to get context" }
        defer { UIGraphicsEndImageContext() }
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: radius, height: radius)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { throw "Unable to get image"}
        
        return img
    }
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
