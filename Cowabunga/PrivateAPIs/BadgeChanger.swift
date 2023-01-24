//
//  BadgeColorChanger.swift
//  DebToIPA
//
//  Created by exerhythm on 16.10.2022.
//

import UIKit
import Dynamic

class BadgeChanger {
    static func change(to color: UIColor, with radius: CGFloat) throws {
        let radius = max(1, radius)
        let badge: UIImage = try UIImage.circle(radius: UIDevice.current.userInterfaceIdiom == .pad ? radius * 2 : radius, color: color)
        let badgeBitmapPath = "/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground:26:26.cpbitmap"
        // create the temp data
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let newFile = temporaryDirectoryURL.appendingPathComponent("TEMP_SBIconBadgeView.BadgeBackground:26:26.cpbitmap")
        badge.writeToCPBitmapFile(to: newFile.path as NSString)
        // get the data created
        let newData = try Data(contentsOf: newFile)
        // overwrite
        let success = overwriteFileWithDataImpl(originPath: badgeBitmapPath, backupName: "SBIconBadgeView.BadgeBackground:26:26.cpbitmap", replacementData: newData)
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

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
