//
//  CodableExtensions.swift
//  
//
//  Created by Serena on 17/10/2022
//

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif

import CoreUIBridge
import UniformTypeIdentifiers

public struct CodableRendition: Codable {
    public var renditionName: String
    public var itemData: Data?
    
    public init(_ rendition: Rendition) {
        self.renditionName = rendition.cuiRend.name()
        
        if let image = rendition.image {
            #if canImport(UIKit)
            let uiImage = UIImage(cgImage: image)
            switch UTType(filenameExtension: (rendition.cuiRend.name() as NSString).lastPathComponent) {
            case UTType.png:
                self.itemData = uiImage.pngData()
            default:
                self.itemData = uiImage.jpegData(compressionQuality: 1.0)
            }
            #elseif canImport(AppKit)
            self.itemData = NSImage(cgImage: image, size: CGSize(width: image.width, height: image.height)).tiffRepresentation
            #endif
            

        } else if let rawData = rendition.cuiRend.srcData {
            self.itemData = rawData
        } else { self.itemData = nil }
    }
    
}

public extension Array where Element == Rendition {
    func toCodable() -> [CodableRendition] {
        return map { rend in
            CodableRendition(rend)
        }
    }
}

