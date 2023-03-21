//
//  Parameters.swift
//  
//
//  Created by Serena on 24/10/2022
//
	

import Foundation
import DiskImages2Bridge

/// A Protocol which where a type implements a method for creating parameters to pass in when attaching a Disk Image.
/// For a default implementation, see the ``AttachParameters`` struct.
public protocol AttachParametersProtocol {
    /// Creates the Disk Images Attach Parameters to pass into the function to attach
    func createDIParams() throws -> DIAttachParams
}

/// A type which describes the basic parameters when attaching a disk image
public struct AttachParameters: Codable, Hashable, AttachParametersProtocol {
    /// The URL of the Disk Image to attach
    public var itemURL: URL
    
    /// The file mode to use when attaching.
    public var fileMode: FileMode
    
    /// A Boolean value describing if DiskImages2 should auto mount the disk image, the effects of this are unknown.
    public var doAutoMount: Bool?
    
    /// A Boolean value describing if DiskImages2 should handle reference counting, the effects of this are unknown.
    public var handleRefCount: Bool?
    
    public func createDIParams() throws -> DIAttachParams {
        let params = try DIAttachParams(url: itemURL)
        params.fileMode = fileMode.rawValue
        
        // if doAutoMount and/or handleRefCount are nil,
        // default to the parameter's default values
        params.autoMount = doAutoMount ?? params.autoMount
        params.handleRefCount = handleRefCount ?? params.handleRefCount
        
        return params
    }
    
    public init(itemURL: URL, fileMode: FileMode = .normal, doAutoMount: Bool? = nil, handleRefCount: Bool? = nil) {
        self.itemURL = itemURL
        self.fileMode = fileMode
        self.doAutoMount = doAutoMount
        self.handleRefCount = handleRefCount
    }
    
    public enum FileMode: Codable, Hashable {
        /// The normal file mode, you most probably want to use this.
        case normal
        
        /// Make sure that the disk image can be read and written to,
        /// this will fail on read-only Disk Images
        case forceReadWrite
        
        /// Another file mode, described by the given `fileModeNumber` parameter.
        case other(fileModeNumber: CLongLong)
        
        public var rawValue: CLongLong {
            switch self {
            case .normal:
                return 0
            case .forceReadWrite:
                return 3
            case .other(let fileModeNum):
                return fileModeNum
            }
        }
    }
}

