//
//  LockManager.swift
//  Cowabunga
//
//  Created by lemin on 1/27/23.
//
// Credit to Haxi0 for original TrollLock

import Foundation
import UIKit
import MacDirtyCowSwift

class LockManager {
    static var testingLocks: Bool = false
    
    static let globalLockPaths: [String] = [
        "3x-d73",
        "3x-896h",
        "3x-812h",
        "2x-896h",
        "2x-812h",
        "2x-120fps~ipad"
    ]
    
    static let deviceLockPath: [String: String] = [
        "iPhone15,3": "3x-d73", // iPhone 14 Pro Max
        "iPhone15,2": "3x-d73", // iPhone 14 Pro
        "iPhone14,7": "3x-812h", // iPhone 14
        
        "iPhone14,3": "3x-812h", // iPhone 13 Pro Max
        "iPhone14,2": "3x-812h", // iPhone 13 Pro
        "iPhone14,5": "3x-812h", // iPhone 13
        "iPhone14,4": "3x-812h", // iPhone 13 Mini
        
        "iPhone13,4": "3x-896h", // iPhone 12 Pro Max
        "iPhone13,3": "3x-812h", // iPhone 12 Pro
        "iPhone13,2": "3x-812h", // iPhone 12
        "iPhone13,1": "3x-812h", // iPhone 12 Mini
        
        "iPhone12,5": "3x-812h", // iPhone 11 Pro Max
        "iPhone12,3": "2x-896h", // iPhone 11 Pro
        "iPhone12,1": "2x-812h", // iPhone 11
        
        "iPhone11,8": "2x-812h", // iPhone XR
        "iPhone11,4": "3x-896h", // iPhone XS Max (China)
        "iPhone11,6": "3x-896h", // iPhone XS Max
        "iPhone11,2": "3x-812h", // iPhone XS
        
        "iPhone10,3": "3x-812h", // iPhone X (GSM)
        "iPhone10,6": "3x-812h" // iPhone X (Global)
    ]
    
    static func getLockType() -> String {
        return UserDefaults.standard.string(forKey: "LockPrefs") ?? globalLockPaths[0]
    }
    
    static func applyLock(lockName: String) -> Bool {
        let originPath: String = "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@" + getLockType() + ".ca"
        let folderURL: URL? = getLockFolder(lockName: lockName)
        
        if folderURL != nil {
            // add to the file contents
            var replacingImgs: String = ""
            var replacingAnim: String = ""
            var animPlist: [String: Double]? = nil
            if !FileManager.default.fileExists(atPath: folderURL!.appendingPathComponent("animations.plist").path) {
                replacingAnim = defaultAnimation
            } else {
                do {
                    let plistData = try Data(contentsOf: folderURL!.appendingPathComponent("animations.plist"))
                    animPlist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Double]
                } catch {
                    print(error.localizedDescription)
                    replacingAnim = defaultAnimation // fall back
                }
            }
            var replacingContents: String = camlFileContents
            for i in 1 ... 120 {
                let newFileURL = folderURL!.appendingPathComponent("trollformation\(i).png")
                if !FileManager.default.fileExists(atPath: newFileURL.path) {
                    if i != 1 {
                        // set the last image
                        replacingContents = replacingContents.replacingOccurrences(of: "FINAL", with: newLockLastText.replacingOccurrences(of: "i", with: folderURL!.appendingPathComponent("trollformation\(i-1).png").absoluteString))
                        break
                    } else {
                        print("No lock images?!")
                        return false
                    }
                }
                if i == 1 {
                    // set first image
                    replacingContents = replacingContents.replacingOccurrences(of: "INITIAL", with: newLockFirstText.replacingOccurrences(of: "i", with: newFileURL.absoluteString))
                }
                replacingImgs += newLockText.replacingOccurrences(of: "i", with: newFileURL.absoluteString)
                if animPlist != nil {
                    if animPlist![String(i)] != nil {
                        replacingAnim += newAnimText.replacingOccurrences(of: "i", with: String(animPlist![String(i)]!))
                    }
                }
            }
            replacingContents = replacingContents.replacingOccurrences(of: "IMAGE_PATHS", with: replacingImgs).replacingOccurrences(of: "ANIMATION", with: replacingAnim)
            
            // write to the path
            let newData: Data? = replacingContents.data(using: .utf8)
            if newData != nil {
                return MDC.overwriteFile(at: originPath + "/main.caml", with: newData!)
            } else {
                print("Failed to replace lock: failed to get data")
                return false
            }
        } else {
            print("Failed to get the lock folder url")
            return false
        }
    }
    
    // get the directory of the saved locks
    static func getLocksDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Saved_Locks")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the saved locks directory")
        }
        return nil
    }
    
    // add an imported lock
    static func addImportedLock(lockName: String, url: URL) throws -> Data {
        if FileManager.default.fileExists(atPath: url.appendingPathComponent("trollformation1.png").path) {
            // it is a valid passcode file
            let newFolder: URL = getLocksDirectory()!.appendingPathComponent(lockName)
            if !FileManager.default.fileExists(atPath: newFolder.path) {
                do {
                    try FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: false)
                } catch {
                    throw "Could not create new directory."
                }
            }
            
            // find animation json if exists
            var animData: [String: Double]? = nil
            var sumFrames: Double = 0
            var finalAnimData: [String: Double] = [:]
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("animations.json").path) {
                do {
                    let jsonData = try Data(contentsOf: url.appendingPathComponent("animations.json"))
                    animData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Double]
                } catch {
                    // delete the created folder
                    do {
                        try FileManager.default.removeItem(at: newFolder)
                    } catch {
                        print(error.localizedDescription)
                    }
                    throw "There was an error parsing animation data! \(error.localizedDescription)"
                }
            }
            
            // fill it with files
            var firstImg: Data? = nil
            var lastAnimFrame: Int = 0
            for i in 1 ... 120 {
                let imgName: String = "trollformation\(i).png"
                let imgURL = url.appendingPathComponent(imgName)
                if FileManager.default.fileExists(atPath: imgURL.path) {
                    do {
                        let imgData = try Data(contentsOf: imgURL)
                        try imgData.write(to: newFolder.appendingPathComponent(imgName))
                        if i == 1 {
                            firstImg = imgData
                        }
                        
                        if animData != nil {
                            if animData![String(i)] != nil {
                                lastAnimFrame = i
                                sumFrames += animData![String(i)]!
                                finalAnimData[String(i)] = sumFrames
                            } else if lastAnimFrame > 0 || i == 1 {
                                if i == 1 {
                                    lastAnimFrame = i
                                }
                                if animData![String(lastAnimFrame)] != nil {
                                    sumFrames += animData![String(lastAnimFrame)]!
                                    finalAnimData[String(i)] = sumFrames
                                }
                            } else {
                                // delete the created folder
                                do {
                                    try FileManager.default.removeItem(at: newFolder)
                                } catch {
                                    print(error.localizedDescription)
                                }
                                throw "No starting frame found for animation!"
                            }
                        }
                    } catch {
                        // delete the created folder
                        do {
                            try FileManager.default.removeItem(at: newFolder)
                        } catch {
                            print(error.localizedDescription)
                        }
                        throw "Could not save image data: \(error.localizedDescription)"
                    }
                } else {
                    if i == 1 {
                        // delete the created folder
                        do {
                            try FileManager.default.removeItem(at: newFolder)
                        } catch {
                            print(error.localizedDescription)
                        }
                        throw "Missing contents in lock folder!"
                    } else {
                        if animData != nil {
                            // create the plist of animations
                            do {
                                let plistURL: URL = newFolder.appendingPathComponent("animations.plist")
                                let newPlistData = try PropertyListSerialization.data(fromPropertyList: finalAnimData, format: .xml, options: 0)
                                try newPlistData.write(to: plistURL)
                            } catch {
                                // delete the created folder
                                do {
                                    try FileManager.default.removeItem(at: newFolder)
                                } catch {
                                    print(error.localizedDescription)
                                }
                                throw "Error saving animation data! \(error.localizedDescription)"
                            }
                        }
                        // return the image
                        return firstImg!
                    }
                }
            }
        } else {
            throw "Not a valid lock theme folder!"
        }
        throw "Could not get image data!"
    }
    
    // get the a folder of locks
    static func getLockFolder(lockName: String) -> URL? {
        do {
            let newURL: URL = getLocksDirectory()!.appendingPathComponent(lockName)
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the " + lockName + " lock directory")
        }
        return nil
    }
    
    private static let newAnimText = "<real value=\"i\"/>\n"
    private static let newLockFirstText = "<contents type=\"CGImage\" src=\"i\"/>"
    private static let newLockLastText = "<value type=\"CGImage\" src=\"i\"/>"
    private static let newLockText = "<CGImage src=\"i\"/>\n"
    private static let defaultAnimation = """
                         <real value=\"0\"/>\
                         <real value=\"0.01666666666\"/>\
                         <real value=\"0.03333333333\"/>\
                         <real value=\"0.05\"/>\
                         <real value=\"0.06666666666\"/>\
                         <real value=\"0.08333333333\"/>\
                         <real value=\"0.1\"/>\
                         <real value=\"0.116666666667\"/>\
                         <real value=\"0.133333333333\"/>\
                         <real value=\"0.15\"/>\
                         <real value=\"0.166666666667\"/>\
                         <real value=\"0.183333333333\"/>\
                         <real value=\"0.2\"/>\
                         <real value=\"0.216666666667\"/>\
                         <real value=\"0.233333333333\"/>\
                         <real value=\"0.25\"/>\
                         <real value=\"0.266666666667\"/>\
                         <real value=\"0.283333333333\"/>\
                         <real value=\"0.3\"/>\
                         <real value=\"0.316666666667\"/>\
                         <real value=\"0.333333333333\"/>\
                         <real value=\"0.35\"/>\
                         <real value=\"0.366666666667\"/>\
                         <real value=\"0.383333333333\"/>\
                         <real value=\"0.4\"/>\
                         <real value=\"0.416666666667\"/>\
                         <real value=\"0.433333333333\"/>\
                         <real value=\"0.45\"/>\
                         <real value=\"0.466666666667\"/>\
                         <real value=\"0.483333333333\"/>\
                         <real value=\"0.5\"/>\
                         <real value=\"0.516666666667\"/>\
                         <real value=\"0.533333333333\"/>\
                         <real value=\"0.55\"/>\
                         <real value=\"0.566666666667\"/>\
                         <real value=\"0.583333333333\"/>\
                         <real value=\"0.6\"/>\
                         <real value=\"0.616666666667\"/>\
                         <real value=\"0.633333333333\"/>\
                         <real value=\"0.65\"/>\
                         <real value=\"0.666666666667\"/>\
                         <real value=\"0.683333333333\"/>\
                         <real value=\"0.7\"/>\
                         <real value=\"0.716666666667\"/>\
                         <real value=\"0.733333333333\"/>\
                         <real value=\"0.75\"/>\
                         <real value=\"0.766666666667\"/>\
                         <real value=\"0.783333333333\"/>\
                         <real value=\"0.8\"/>\
                         <real value=\"0.816666666667\"/>\
                         <real value=\"0.833333333333\"/>\
                         <real value=\"0.85\"/>\
                         <real value=\"0.866666666667\"/>\
                         <real value=\"0.883333333333\"/>\
                         <real value=\"0.9\"/>\n
    """
    
    private static var camlFileContents = """
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>\
     <caml xmlns=\"http://www.apple.com/CoreAnimation/1.0\">\
       <CALayer allowsEdgeAntialiasing=\"1\" allowsGroupOpacity=\"1\" bounds=\"0 0 69.0 100.0\" contentsFormat=\"RGBA8\" name=\"root\" position=\"34.5 50.0\">\
         <sublayers>\
           <CALayer id=\"#3\" allowsEdgeAntialiasing=\"1\" allowsGroupOpacity=\"1\" bounds=\"0 0 147.0 132.0\" contentsFormat=\"RGBA8\" geometryFlipped=\"1\" name=\"container\" position=\"34.5 50.0\">\
               <sublayers>\
                 <CALayer id=\"#2\" allowsEdgeAntialiasing=\"1\" allowsGroupOpacity=\"1\" bounds=\"0 0 147.0 132.0\" contentsFormat=\"RGBA8\" name=\"shake\" position=\"73.5 66.0\">\
                   <sublayers>\
                     <CALayer id=\"#1\" allowsEdgeAntialiasing=\"1\" allowsGroupOpacity=\"1\" bounds=\"0 0 147.0 132.0\" contentsFormat=\"RGBA8\" name=\"shackle\" opacity=\"1\" position=\"73.5 66.0\">\
                       INITIAL\
                     </CALayer>\
                   </sublayers>\
                 </CALayer>\
               </sublayers>\
             </CALayer>\
           </sublayers>\
         <states>\
           <LKState name=\"Sleep\">\
         <elements>\
           <LKStateSetValue final=\"false\" targetId=\"#3\" keyPath=\"transform.scale.xy\">\
             <value type=\"real\" value=\"0.75\"/>\
           </LKStateSetValue>\
           <LKStateSetValue final=\"false\" targetId=\"#3\" keyPath=\"opacity\">\
             <value type=\"integer\" value=\"0\"/>\
           </LKStateSetValue>\
         </elements>\
           </LKState>\
           <LKState name=\"Locked\"/>\
           <LKState name=\"Unlocked\">\
         <elements>\
           <LKStateSetValue final=\"false\" targetId=\"#1\" keyPath=\"contents\">\
             FINAL\
           </LKStateSetValue>\
         </elements>\
           </LKState>\
           <LKState name=\"Error\">\
         <elements>\
           <LKStateSetValue final=\"false\" targetId=\"#2\" keyPath=\"position.x\">\
             <value type=\"real\" value=\"113.5\"/>\
           </LKStateSetValue>\
           <LKStateSetValue final=\"false\" targetId=\"#3\" keyPath=\"position.x\">\
             <value type=\"real\" value=\"-5.5\"/>\
           </LKStateSetValue>\
         </elements>\
           </LKState>\
         </states>\
         <stateTransitions>\
           <LKStateTransition fromState=\"*\" toState=\"Unlocked\">\
         <elements>\
           <LKStateTransitionElement final=\"false\" key=\"contents\" targetId=\"#1\">\
             <animation type=\"CAKeyframeAnimation\" calculationMode=\"discrete\" keyPath=\"contents\" duration=\"1\" fillMode=\"backwards\" timingFunction=\"linear\">\
               <keyTimes>\
                     ANIMATION</keyTimes>\
               <values>\
                     IMAGE_PATHS</values>\
             </animation>\
           </LKStateTransitionElement>\
         </elements>\
           </LKStateTransition>\
           <LKStateTransition fromState=\"Unlocked\" toState=\"*\">\
         <elements/>\
           </LKStateTransition>\
           <LKStateTransition fromState=\"*\" toState=\"Sleep\">\
         <elements>\
           <LKStateTransitionElement final=\"false\" key=\"transform.scale.xy\" targetId=\"#3\">\
             <animation type=\"CABasicAnimation\" keyPath=\"transform.scale.xy\" duration=\"0.25\" fillMode=\"backwards\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
           <LKStateTransitionElement final=\"false\" key=\"opacity\" targetId=\"#3\">\
             <animation type=\"CABasicAnimation\" keyPath=\"opacity\" duration=\"0.25\" fillMode=\"backwards\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
         </elements>\
           </LKStateTransition>\
           <LKStateTransition fromState=\"Sleep\" toState=\"*\">\
         <elements>\
           <LKStateTransitionElement final=\"false\" key=\"transform.scale.xy\" targetId=\"#3\">\
             <animation type=\"CABasicAnimation\" keyPath=\"transform.scale.xy\" duration=\"0.25\" fillMode=\"backwards\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
           <LKStateTransitionElement final=\"false\" key=\"opacity\" targetId=\"#3\">\
             <animation type=\"CABasicAnimation\" keyPath=\"opacity\" duration=\"0.25\" fillMode=\"backwards\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
         </elements>\
           </LKStateTransition>\
           <LKStateTransition fromState=\"*\" toState=\"Error\">\
         <elements>\
           <LKStateTransitionElement final=\"false\" key=\"position.x\" targetId=\"#3\">\
             <animation type=\"CABasicAnimation\" keyPath=\"position.x\" duration=\"0.2\" fillMode=\"both\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
           <LKStateTransitionElement final=\"false\" key=\"position.x\" targetId=\"#2\">\
             <animation type=\"CASpringAnimation\" damping=\"40\" mass=\"3\" stiffness=\"2200\" keyPath=\"position.x\" beginTime=\"0.075\" duration=\"0.78\" fillMode=\"both\" speed=\"1.4\"/>\
           </LKStateTransitionElement>\
         </elements>\
           </LKStateTransition>\
           <LKStateTransition fromState=\"Error\" toState=\"*\">\
         <elements>\
           <LKStateTransitionElement final=\"false\" key=\"position.x\" targetId=\"#3\">\
             <animation type=\"CABasicAnimation\" keyPath=\"position.x\" duration=\"0.25\" fillMode=\"backwards\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
           <LKStateTransitionElement final=\"false\" key=\"position.x\" targetId=\"#2\">\
             <animation type=\"CABasicAnimation\" keyPath=\"position.x\" duration=\"0.25\" fillMode=\"backwards\" timingFunction=\"default\"/>\
           </LKStateTransitionElement>\
         </elements>\
           </LKStateTransition>\
         </stateTransitions>\
       </CALayer>\
     </caml>\
    
    """
}
