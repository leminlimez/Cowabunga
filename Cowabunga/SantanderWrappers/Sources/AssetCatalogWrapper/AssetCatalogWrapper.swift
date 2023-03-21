//
//  CarWrapper.swift
//  Santander
//
//  Created by Serena on 16/09/2022
//


#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

import UniformTypeIdentifiers
import CoreSVGBridge

@_exported
import CoreUIBridge

public typealias RenditionCollection = [(type: RenditionType, renditions: [Rendition])]

internal func _getScreenScale() -> CGFloat {
    #if canImport(UIKit)
    return UIScreen.main.scale
    #else
    return NSScreen.main!.backingScaleFactor
    #endif
}

public class AssetCatalogWrapper {
    public static let shared = AssetCatalogWrapper()
    
    public func renditions(forCarArchive url: URL) throws -> (CUICatalog, RenditionCollection) {
        let catalog = try CUICatalog(url: url)
        return (catalog, catalog.__getRenditionCollection())
    }
    /*
    public func renditions(forBundle bundle: Bundle) throws -> (CUICatalog, RenditionCollection) {
        let catalog = CUICatalog.defaultUICatalog(for: bundle)
        return (catalog, catalog.__getRenditionCollection())
    }
     */
}

/// Represents a Core UI rendition
public class Rendition: Hashable {
    
    /// the ThemeSubtype constant used to identify renditions
    /// classified as `macCatalyst`
    /// see `RenditionIdiom`'s init
    public static let macCatalystSubtype = 32401
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cuiRend)
        hasher.combine(namedLookup)
        hasher.combine(type)
    }
    
    public static func == (lhs: Rendition, rhs: Rendition) -> Bool {
        return lhs.cuiRend == rhs.cuiRend && lhs.namedLookup == rhs.namedLookup && lhs.type == rhs.type
    }
    
    public let cuiRend: CUIThemeRendition
    public let namedLookup: CUINamedLookup
    public let type: RenditionType
    public let name: String
    
    @available(*, unavailable, message: "Renamed to `representation`")
    public var preview: Representation? { fatalError() }
    
    public lazy var representation: Representation? = Representation(self)
    public lazy var image: CGImage? = _getImage()
    
    public func _getImage() -> CGImage? {
        if let cgImage = cuiRend.uncroppedImage()?.takeUnretainedValue() {
            return cgImage
        }
        
        switch type {
        case .pdf:
            return cuiRend.createImageFromPDFRendition(withScale: _getScreenScale())?.takeUnretainedValue()
        case .svg:
            // https://github.com/showxu/cartools/blob/ccb872e0cc819c9d800d8a5cc65f558d7a1e31f4/cartooldt/CoreUIExt.swift#L64
            let w = Int(ceil(CGSVGDocumentGetCanvasSize(cuiRend.svgDocument()).width))
            let h = Int(ceil(CGSVGDocumentGetCanvasSize(cuiRend.svgDocument()).height))
            let c = CGContext(data: nil,
                              width: w,
                              height: h,
                              bitsPerComponent: 8,
                              bytesPerRow: 0,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            CGContextDrawSVGDocument(c, cuiRend.svgDocument())
            return c?.makeImage()
        default:
            return nil
        }
        
    }
    
    public init(_ namedLookup: CUINamedLookup) {
        let rendition = namedLookup.rendition
        self.cuiRend = rendition
        self.namedLookup = namedLookup
        self.type = .init(namedLookup: namedLookup)
        
        self.name = type == .icon ? cuiRend.name() : namedLookup.name
    }
    
    #if canImport(UIKit)
    public func makeDragItem() -> UIDragItem? {
        guard let cgImage = self.image else { return nil }
        
        let image = UIImage(cgImage: cgImage)
        let itemProvider = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = image
        
        return dragItem
    }
    #endif
    
    /// The idiom, aka the platform target, of a Rendition
    public enum Idiom: CustomStringConvertible {
        /// All platforms.
        case universal
        
        case iphone
        case ipad
        case tv
        case watch
        case carPlay
        case macCatalyst
        
        /// This seems to be for App Store related renditions.
        case marketing
        
        public init?(_ keyList: CUIRenditionKey) {
            if keyList.themeSubtype == Rendition.macCatalystSubtype {
                self = .macCatalyst
                return
            }
            
            switch keyList.themeIdiom {
            case 0:
                self = .universal
            case 1:
                self = .iphone
            case 2:
                self = .ipad
            case 3:
                self = .tv
            case 4:
                self = .carPlay
            case 5:
                self = .watch
            case 6:
                self = .marketing
            default:
                return nil
            }
        }
        
        public var description: String {
            switch self {
            case .universal:
                return "Universal"
            case .iphone:
                return "iPhone"
            case .ipad:
                return "iPad"
            case .tv:
                return "TV"
            case .watch:
                return "Watch"
            case .carPlay:
                return "CarPlay"
            case .macCatalyst:
                return "Mac Catalyst"
            case .marketing:
                return "Marketing"
            }
        }
    }
    
    public enum DisplayGamut: Int64, Hashable, CustomStringConvertible {
        case sRGB = 0
        case p3 = 1
        
        public init?(_ key: CUIRenditionKey) {
            self.init(rawValue: key.themeDisplayGamut)
        }
        
        public var description: String {
            switch self {
            case .sRGB:
                return "SRGB"
            case .p3:
                return "Display P3"
            }
        }
    }
    
    public enum Appearance: Int64, CustomStringConvertible {
        case any = 0
        case dark = 1
        case highContrast = 2
        case highConstrastDark = 3
        case light = 4
        case highConstrastLight = 5
        
        public init?(_ key: CUIRenditionKey) {
            self.init(rawValue: key.themeAppearance)
        }
        
        public var description: String {
            switch self {
            case .any:
                return "Any"
            case .dark:
                return "Dark"
            case .light:
                return "Light"
            case .highContrast:
                return "High Constrast"
            case .highConstrastDark:
                return "High Contrast Dark"
            case .highConstrastLight:
                return "High Constrast Light"
            }
        }
    }
    
    public enum Representation: Hashable {
        case color(CGColor)
        case image(CGImage)
        
        #if canImport(UIKit)
        public var uiView: UIView {
            var view = UIView()
            switch self {
            case .color(let cgColor):
                view.backgroundColor = UIColor(cgColor: cgColor)
            case .image(let cgImage):
                view = UIImageView(image: UIImage(cgImage: cgImage))
                view.clipsToBounds = true
            }
            
            return view
        }
        /*
        #else
        public var nsView: NSView {
            switch self {
            case .color(let color):
                let view = NSView()
                view.wantsLayer = true
                view.layer?.backgroundColor = color
                return view
            case .image(let image):
                return NSImageView(image: NSImage(cgImage: image,
                                                  size: CGSize(width: image.width, height: image.height)))
            }
        }
         */
        #endif
        
        public init?(_ rendition: Rendition) {
            if let cgColor = rendition.cuiRend.cgColor()?.takeUnretainedValue() {
                self = .color(cgColor)
            } else if let image = rendition.image {
                self = .image(image)
            } else {
                return nil
            }
        }
    }
}

public enum RenditionType: Int, Codable, Hashable, CustomStringConvertible, CaseIterable {
    case image, icon, imageSet, multiSizeImageSet
    case pdf
    case color
    case svg
    case rawData
    case unknown
    
    public init(namedLookup: CUINamedLookup) {
        let className = String(describing: namedLookup.rendition.classForCoder)
        
        switch className {
        case "_CUIRawPixelRendition": // non PNG images? lmao
            self = .image
        case "_CUIThemePixelRendition", "_CUIInternalLinkRendition":
            let key = namedLookup.key
            
            switch key.themeElement {
            case 85 where key.themePart == 220 :
                self = .icon
            case 9:
                self = .imageSet
            default:
                self = .image
            }
        case "_CUIThemePDFRendition":
            self = .pdf
        case "_CUIThemeColorRendition":
            self = .color
        case "_CUIThemeSVGRendition":
            self = .svg
        case "_CUIThemeMultisizeImageSetRendition":
            self = .multiSizeImageSet
        case "_CUIRawDataRendition":
            self = .rawData
        default:
            self = .unknown
        }
    }
    
    public var description: String {
        switch self {
        case .image:
            return "Image"
        case .icon:
            return "Icon"
        case .imageSet:
            return "Image Set"
        case .multiSizeImageSet:
            return "Multisize Image Set"
        case .pdf:
            return "PDF"
        case .color:
            return "Color"
        case .svg:
            return "SVG (Vector)"
        case .rawData:
            return "Raw Data"
        case .unknown:
            return "Unknown"
        }
    }
    
    public var isEditable: Bool {
        switch self {
        case .image, .icon, .color:
            return true
        default:
            return false
        }
    }
    
}

@available(*, deprecated, message: "Renamed to Rendition.Representation")
public typealias RenditionPreview = Rendition.Representation

public extension CUICatalog {
    
    internal func __getRenditionCollection() -> RenditionCollection {
        var dict: [RenditionType: [Rendition]] = [:]
        
        enumerateNamedLookups { lookup in
            let rend = Rendition(lookup)
            if var existing = dict[rend.type] {
                existing.append(rend)
                dict[rend.type] = existing
            } else {
                dict[rend.type] = [rend]
            }
        }
        
        var arr = RenditionCollection()
        for (key, value) in dict {
            arr.append((key, value))
        }
        
        // sort by Alphabetical order
        arr = arr.sorted { first, second in
            return first.type.description < second.type.description
        }
        
        return arr
    }
    
    /// Removes an item, and returns a new, updated catalog for the file URL
    func removeItem(_ rendition: Rendition, fileURL: URL) throws {
        let keyStore = try removingItem(rendition, fileURL: fileURL)
        try writekeyStore(keyStore, to: fileURL)
    }
    
    /// Removes an item, and returns a new, updated catalog for the file URL
    func removingItem(_ rendition: Rendition, fileURL: URL) throws -> CUIMutableCommonAssetStorage {
        let keyStore = try keyStore(forFileURL: fileURL)
        guard let data = _themeStore().convertRenditionKey(toKeyData: rendition.cuiRend.key()) else {
            throw _Errors.unableToAccessItemData
        }
        
        keyStore.removeAsset(forKey: data)
        return keyStore
    }
    
    func editItem(_ item: Rendition, fileURL: URL, to newValue: Rendition.Representation) throws {
        let keyStore = try editingItem(item, fileURL: fileURL, to: newValue)
        try writekeyStore(keyStore, to: fileURL)
    }
    
    func editingItem(_ item: Rendition, fileURL: URL, to newValue: Rendition.Representation) throws -> CUIMutableCommonAssetStorage {
        guard let keyStore = CUIMutableCommonAssetStorage(path: fileURL.path, forWriting: true) else {
            throw _Errors.unableToAccessCatalogFile(fileURL: fileURL)
        }
        
        // refactored from https://github.com/joey-gm/Aphrodite/blob/a334eb6a7c4863897723c968bd7a083ae1df75b9/Aphrodite/Models/AssetCatalog.swift#L181
        switch newValue {
        case .image(let newImage):
            var rendition = item.cuiRend
            let assetStorage = keyStore
            let themeStore = _themeStore()
            
            let isInternalLink: Bool = rendition.isInternalLink()
            let linkRect: CGRect = rendition._destinationFrame()
            let keyList = rendition.linkingToRendition()?.keyList() ?? item.namedLookup.key.keyList()
            
            var carKey = themeStore.convertRenditionKey(toKeyData: keyList)
            if isInternalLink {
                let keyList = rendition.linkingToRendition()?.keyList()
                carKey = themeStore.convertRenditionKey(toKeyData: keyList)
                rendition = CUIThemeRendition(csiData: assetStorage.asset(forKey: carKey!), forKey: keyList)
            }
            
            guard let carKey = carKey else {
                throw _Errors.failedToEditItem(lineFailed: #line)
            }
            
            let unslicedSize: CGSize = CGSize(width: newImage.width, height: newImage.height)
            let renditionLayout = rendition.type == 0 ? Int16(rendition.subtype) : Int16(rendition.type)
            guard let generator = CSIGenerator(canvasSize: unslicedSize, sliceCount: 1, layout: renditionLayout),
                  let wrapper = CSIBitmapWrapper(pixelWidth: UInt32(unslicedSize.width),
                                                 pixelHeight: UInt32(unslicedSize.height))
            else {
                throw _Errors.failedToEditItem()
            }
            
            let context = Unmanaged<CGContext>.fromOpaque(wrapper.bitmapContext()).takeUnretainedValue()
            
            if isInternalLink {
                if let existingImage = rendition.unslicedImage()?.takeUnretainedValue() {
                    context.draw(existingImage, in: CGRect(origin: .zero, size: unslicedSize))
                    context.clear(linkRect.insetBy(dx: -2, dy: -2)) // clear the original image and the 2px broader
                }
                
                context.draw(newImage, in: linkRect)
            } else {
                context.draw(newImage, in: CGRect(origin: .zero, size: unslicedSize))
            }
            
            //Add Bitmap Wrapper and Set Rendition Properties
            generator.addBitmap(wrapper)
            generator.addSliceRect(rendition._destinationFrame())
            generator.prepareToEdit(forRendition: rendition)
            
            guard let csiRep = generator.csiRepresentation(withCompression: true) else {
                throw _Errors.failedToEditItem()
            }
            
            assetStorage.setAsset(csiRep, forKey: carKey)
        case .color(let cgColor):
            let components = try cgColor.components.unwrap("Failed to edit item \(item.name): Failed to get color components of new color.")
            let generator = try CSIGenerator(colorNamed: nil,
                                             colorSpaceID: UInt(item.cuiRend.colorSpaceID()), components: components)
                .unwrap("Failed to edit item \(item.name): Failed to generate a CSIGenerator in order to edit the item.")
            
            let csiRepresentation = try generator.csiRepresentation(withCompression: true)
                .unwrap("Failed to generate CSI Representation of the new color.")
            
            let themeStore = _themeStore()
            let keyData = try themeStore.convertRenditionKey(toKeyData: item.namedLookup.key.keyList())
                .unwrap("Failed to generate data of new item.")
            guard keyStore.setAsset(csiRepresentation, forKey: keyData) else {
                throw _Errors.failedToEditItem(description: "Failed to set new data for asset.")
            }
        }
        
        return keyStore
    }
    
    // so we don't have to repeat code above
    private func keyStore(forFileURL fileURL: URL) throws -> CUIMutableCommonAssetStorage {
        guard let keyStore = CUIMutableCommonAssetStorage(path: fileURL.path, forWriting: true) else {
            throw _Errors.unableToAccessCatalogFile(fileURL: fileURL)
        }
        
        return keyStore
    }
    
    private func writekeyStore(_ keyStore: CUIMutableCommonAssetStorage, to fileURL: URL) throws {
        guard keyStore.writeToDisk(compact: true) else {
            throw _Errors.unableToWriteToCatalogFile(fileURL: fileURL)
        }
    }
    
    private enum _Errors: Error, LocalizedError {
        case unableToAccessCatalogFile(fileURL: URL)
        case unableToWriteToCatalogFile(fileURL: URL)
        
        // for when `convertRenditionKey` fails
        case unableToAccessItemData
        
        case failedToEditItem(lineFailed: Int = #line, file: String = #file, description: String? = nil)
        
        var errorDescription: String? {
            switch self {
            case .unableToAccessCatalogFile(let fileURL):
                return "Unable to init CUIMutableCommonAssetStorage for \(fileURL.path)"
            case .unableToWriteToCatalogFile(let fileURL):
                return "Unable to write to catalog file \(fileURL.lastPathComponent)"
            case .unableToAccessItemData:
                return "Unable to access data of item"
            case .failedToEditItem(let lineFailed, let file, let description):
                #if DEBUG
                return "Failed to edit item, failed at \(file):\(lineFailed), cause: \(description ?? "Unknown.")"
                #else
                return "Failed to edit item: \(description ?? "unknown cause. Blame CoreUI!")"
                #endif
            }
        }
    }
    
}

private extension CSIGenerator {
    func prepareToEdit(forRendition rendition: CUIThemeRendition) {
        let flags = rendition.renditionFlags()?.pointee
        
        name = rendition.name()
        blendMode = rendition.blendMode
        
        colorSpaceID                  = Int16(rendition.colorSpaceID())
        exifOrientation               = rendition.exifOrientation
        opacity                       = rendition.opacity
        scaleFactor                   = UInt32(rendition.scale())
        templateRenderingMode         = rendition.templateRenderingMode()
        utiType                       = rendition.utiType()
        isVectorBased                 = rendition.isVectorBased()
        excludedFromContrastFilter    = Bool(truncating: (flags?.isExcludedFromContrastFilter ?? 0) as NSNumber)
    }
}

internal extension Optional {
    func unwrap(orThrow error: Error) throws -> Wrapped {
        guard let self = self else { throw error }
        return self
    }
    
    func unwrap(_ error: String) throws -> Wrapped {
        return try self.unwrap(orThrow: _Error.stringError(error))
    }
    
    // private enum
    private enum _Error: Error, LocalizedError {
        case stringError(String)
        
        var errorDescription: String? {
            switch self {
            case .stringError(let description):
                return description
            }
        }
    }
}
