//
//  SVGDocument.swift
//  
//
//  Created by Serena on 29/10/2022
//


@_exported
import CoreSVGBridge
import Foundation

public class SVGDocument {
    public var doc: CGSVGDocumentRef
    
    public init(doc: CGSVGDocumentRef) {
        self.doc = doc
    }
    
    convenience public init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        self.init(data: data)
    }
    
    convenience public init(fileURL: URL) throws {
        self.init(data: try Data(contentsOf: fileURL))
    }
    
    public init(data: Data) {
        self.doc = CGSVGDocumentCreateFromData(data as CFData, nil)
    }
    
//    public var canvasSize: CGSize {
//        return CGSVGDocumentGetCanvasSize(doc)
//    }
    
    #if canImport(UIKit)
    public func image(configuration: ImageCreationConfiguration? = nil) -> UIImage {
        if let configuration = configuration {
            return UIImage(svgDocument: doc, scale: configuration.scale, orientation: configuration.orientation)
        }
        
        return UIImage(svgDocument: doc)
    }
    
    public struct ImageCreationConfiguration: Hashable {
        public let scale: CGFloat
        public let orientation: UIImage.Orientation
        
        public init(scale: CGFloat, orientation: UIImage.Orientation) {
            self.scale = scale
            self.orientation = orientation
        }
    }
    #endif
    
    public func write(to url: URL) {
        CGSVGDocumentWriteToURL(doc, url as CFURL, nil)
    }
    
    deinit {
        CGSVGDocumentRelease(doc)
    }
}
