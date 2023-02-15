//
//  WhitelistFunctions.swift
//  Cowabunga
//
//  Created by Hariz Shirazi on 2023-02-12.
//

import Foundation
import MacDirtyCowSwift

public struct Whitelist {
    public static let blankplist = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdC8+CjwvcGxpc3Q+Cg=="
    
    public static func overwriteBlacklist() -> Bool {
        return MDC.overwriteFile(at: "/private/var/db/MobileIdentityData/Rejections.plist", with: Data(base64Encoded: blankplist)!)
    }
    
    public static func overwriteBannedApps() -> Bool {
        return MDC.overwriteFile(at: "/private/var/db/MobileIdentityData/AuthListBannedUpps.plist", with: Data(base64Encoded: blankplist)!)
    }
    
    public static func overwriteCdHashes() -> Bool {
        return MDC.overwriteFile(at: "/private/var/db/MobileIdentityData/AuthListBannedCdHashes.plist", with: Data(base64Encoded: blankplist)!)
    }
    
    public static func readFile(path: String) -> String? {
        return (try? String?(String(contentsOfFile: path)) ?? "ERROR: Could not read from file! Does it even exist?")
    }
}
