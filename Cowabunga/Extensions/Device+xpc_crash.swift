//
//  Device+xpc_crash.swift
//  Cowabunga
//
//  Created by sourcelocation on 08/02/2023.
//

import Foundation

func xpc_crash(_ serviceName: String) {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: serviceName.utf8.count)
    defer { buffer.deallocate() }
    strcpy(buffer, serviceName)
    xpc_crasher(buffer)
}
