//
//  DeviceHandle.swift
//  
//
//  Created by Serena on 24/10/2022
//


import Foundation
import DiskImages2Bridge

/// A type describing info of a device handle, returned after a disk image has been attached
public struct DeviceHandle: Codable, Hashable, CustomStringConvertible {
    
    /// The name of the attached device, known as the "BSD Name" in DiskImages2
    public let name: String
    
    /// The ID of the device attached in the IOKit Registry Entry,
    /// see functions prefixed with `IORegistryEntry` on https://developer.apple.com/documentation/iokit/iokitlib_h
    public let registryEntryID: UInt
    
    public let handlesRefCount: Bool
    
    /// The path to this handle, on disk
    /// Note: this path may or may not exist on disk, please check for if it does before using.
    public let deviceHandlePath: URL
    
    public var description: String {
        return "Name: \(name), Full Path (unverified): \(deviceHandlePath.path), Registry Entry ID: \(registryEntryID)"
    }
    
    internal init(_ diDeviceHandle: DIDeviceHandle) {
        self.name = diDeviceHandle.bsdName
        self.registryEntryID = diDeviceHandle.regEntryID
        self.handlesRefCount = diDeviceHandle.handleRefCount
        
        self.deviceHandlePath = URL(fileURLWithPath: "/dev").appendingPathComponent(name)
    }
}
