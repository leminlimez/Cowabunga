//
//  JIT.swift
//  DirtyJIT
//
//  Created by Анохин Юрий on 03.03.2023.
//

import Foundation
import UIKit
import MacDirtyCowSwift

class JIT {
    static var shared = JIT()
    
    func replaceDebug() {
        do {
            let fileData = try Data(contentsOf: Bundle.main.url(forResource: "cert", withExtension: "pem")!)
            try MDC.overwriteFile(at: "/System/Library/Lockdown/iPhoneDebug.pem", with: fileData)
            UIApplication.shared.alert(title: "Done", body: "Successfully replaced the certificate, you may safely connect your phone to your PC now.", withButton: true)
        } catch {
            UIApplication.shared.alert(title: "Error", body: "Failed to replace iPhoneDebug.pem with the cert.pem!", withButton: true)
        }
    }
    
    func returnPID(exec: String) -> String {
        var toReturn = ""
        
        do {
            let string = try String(contentsOfFile: "/var/tmp/ps.log")
            toReturn = findPID(from: string, process: exec)!
        } catch {
            UIApplication.shared.alert(title: "Error", body: "Failed to get PID of executable!", withButton: true)
        }
        
        return toReturn
    }
    
    func findPID(from input: String, process exec: String) -> String? {
        let lines = input.split(separator: "\n")
        for index in stride(from: lines.count - 1, through: 0, by: -1) {
            let line = lines[index]
            if line.contains(exec) {
                let numbers = line.split(separator: " ").last { substr in
                    substr.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
                }
                return String(numbers ?? "")
            }
        }
        return nil
    }
    
    func enableJIT(pidApp: String) {
        let pid = pidApp
        let args: [String] = [pid]
        let argc = args.count
        
        let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: argc + 1)
        defer {
            argv.deallocate()
        }
        
        for i in 0 ..< argc {
            argv[i+1] = strdup(args[i])
        }
        
        jit(Int32(argc+1), argv)
    }
}
