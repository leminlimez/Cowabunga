//
//  ApplicationsManager.swift
//  Santander
//
//  Created by Serena on 15/08/2022.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@_exported import LaunchServicesBridge

/// A Swift Wrapper to manage Applications
public struct ApplicationsManager {
    public let allApps: [LSApplicationProxy]
    public static let shared = ApplicationsManager(allApps: LSApplicationWorkspace.default().allApplications())
    
    public func application(forContainerURL containerURL: URL) -> LSApplicationProxy? {
        return allApps.first { app in
            app.containerURL() == containerURL
        }
    }
    
    public func application(forBundleURL bundleURL: URL) -> LSApplicationProxy? {
        return allApps.first { app in
            app.bundleURL() == bundleURL
        }
    }
    
    public func application(forDataContainerURL dataContainerURL: URL) -> LSApplicationProxy? {
        return allApps.first { app in
            app.bundleContainerURL == dataContainerURL
        }
    }
    
    public func deleteApp(_ app: LSApplicationProxy) throws {
        let errorPointer: NSErrorPointer = nil
        let didSucceed = LSApplicationWorkspace.default().uninstallApplication(app.applicationIdentifier(), withOptions: nil, error: errorPointer, usingBlock: nil)
        if let error = errorPointer?.pointee {
            throw error
        }
        
        guard didSucceed else {
            throw Errors.unableToUninstallApplication(appBundleID: app.applicationIdentifier())
        }
    }
    
    #if canImport(UIKit)
    public func icon(forApplication app: LSApplicationProxy, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        return ._applicationIconImage(forBundleIdentifier: app.applicationIdentifier(), format: 1, scale: scale)
    }
    #elseif canImport(AppKit)
    public func icon(forApplication app: LSApplicationProxy) -> NSImage {
        return NSWorkspace.shared.icon(forFile: app.bundleURL().path)
    }
    #endif
    
    public func openApp(_ app: LSApplicationProxy) throws {
        guard LSApplicationWorkspace.default().openApplication(withBundleID: app.applicationIdentifier()) else {
            throw Errors.unableToOpenApplication(appBundleID: app.applicationIdentifier())
        }
    }
    
    public enum Errors: Error, LocalizedError {
        case unableToOpenApplication(appBundleID: String)
        case unableToUninstallApplication(appBundleID: String)
        
        public var errorDescription: String? {
            switch self {
            case .unableToOpenApplication(let bundleID):
                return "Unable to open Application with Bundle ID \(bundleID)"
            case .unableToUninstallApplication(let bundleID):
                return "Unable to delete Application with Bundle ID \(bundleID)"
            }
        }
    }
}

