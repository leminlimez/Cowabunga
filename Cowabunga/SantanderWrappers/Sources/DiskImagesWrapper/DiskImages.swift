//
//  DiskImages.swift
//  
//
//  Created by Serena on 24/10/2022
//
	

import Foundation
import DiskImages2Bridge

// export DIAttachParams
@_exported import DiskImages2Parameters

public class DiskImages {
    public static let shared = DiskImages()
    
    private init() {}
    
    @discardableResult
    /// Attaches a disk image through the given parameters, see the ``AttachParameters`` struct.
    public func attachDiskImage<Parameters: AttachParametersProtocol>(with params: Parameters) throws -> DeviceHandle {
        let diParams: DIAttachParams
        do {
            diParams = try params.createDIParams()
        } catch {
            throw Errors.failedToCreateParameters(errorEncountered: error)
        }
        
        var diHandle: DIDeviceHandle? = nil
        try DiskImages2.attach(with: diParams, handle: &diHandle)
        guard let diHandle = diHandle else {
            throw Errors.noHandlerReturned
        }
        
        return DeviceHandle(diHandle)
    }
    
    /// Returns the disk image URL of an attached device
    /// ie, if /dev/disk7 was originally attached from DMG at /var/mobile/random.dmg
    /// then calling `diskimageURL(ofDeviceAt: URL(fileURLWithPath: "/dev/disk7")`
    /// would return
    public func diskImageURL(ofDeviceAt deviceURL: URL) throws -> URL {
        return try DiskImages2.imageURL(fromDevice: deviceURL)
    }
    
    /// Detach (aka eject) a device at the given URL
    public func detachDevice(at deviceURL: URL) throws {
        try deviceURL.withUnsafeFileSystemRepresentation { fsRep in
            guard let fsRep = fsRep else {
                throw Errors.failedToGenerateFSRepresentation(path: deviceURL)
            }
            
            let fd = open(fsRep, O_RDONLY)
            guard fd != -1 else {
                throw Errors.failedToOpenDevice(deviceURL: deviceURL)
            }
            
            defer { close(fd) }
            
            let ejectCode = _ioctlRequestCode(forGroup: "d", number: 21)
            let ioctlReturnCode = ioctl(fd, ejectCode)
            guard ioctlReturnCode != -1 else {
                throw Errors.failedToDetachDevice(deviceURL: deviceURL)
            }
        }
    }
    
    private func _ioctlRequestCode(forGroup group: Character, number: UInt) -> UInt {
        let void = UInt(IOC_VOID)
        let g = UInt(group.asciiValue!) << 8
        return void | g | number
    }
}


extension DiskImages {
    // MARK: - Possible Errors
    private enum Errors: Error, LocalizedError, CustomStringConvertible {
        case failedToCreateParameters(errorEncountered: Error)
        case failedToGenerateFSRepresentation(path: URL)
        case failedToOpenDevice(deviceURL: URL)
        case failedToDetachDevice(deviceURL: URL)
        case noHandlerReturned
        
        var description: String {
            switch self {
            case .failedToCreateParameters(let errorEncountered):
                return "Error encountered while trying to create parameters to attach disk image: \(errorEncountered.localizedDescription)"
            case .failedToGenerateFSRepresentation(let path):
                return "Failed to generate file system representation of path \(path.path), could this path be invalid (ie, characters in this path's name are not allowed on this FileSystem)?"
            case .failedToOpenDevice(let deviceURL):
                return "Failed to open and get file descriptor of device at \(deviceURL.path): \(String(cString: strerror(errno)))"
            case .failedToDetachDevice(let deviceURL):
                return "Failed to detach (aka eject) device at path \(deviceURL.path): \(String(cString: strerror(errno)))"
            case .noHandlerReturned:
                return "(Supposedly) attached disk image, however a handler pointing to it was not returned."
            }
        }
        
        var errorDescription: String? {
            description
        }
    }
}
