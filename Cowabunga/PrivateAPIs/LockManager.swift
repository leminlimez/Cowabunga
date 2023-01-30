//
//  LockManager.swift
//  Cowabunga
//
//  Created by lemin on 1/27/23.
//
// Credit to Haxi0 for original TrollLock

import Foundation

class LockManager {
    static var testingLocks: Bool = false
    
    static func applyLock(lockName: String, lockType: String, isCustom: Bool) -> Bool {
        let originPath: String = "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@" + lockType + ".ca"
        let folderURL: URL? = getLockFolder(lockName: lockName, isCustom: isCustom)
        
        if folderURL != nil {
            // add to the file contents
            var replacingContents: String = camlFileContents
            for i in 1 ... 40 {
                let newFile = folderURL!.appendingPathComponent("trollformation" + String(i) + ".png").absoluteString
                replacingContents = replacingContents.replacingOccurrences(of: "trolling" + String(i) + "x", with: newFile)
            }
            
            // write to the path
            let newData: Data? = replacingContents.data(using: .utf8)
            if newData != nil {
                return overwriteFileWithDataImpl(originPath: originPath + "/main.caml", replacementData: newData!)
            } else {
                print("Failed to replace lock: failed to get data")
                return false
            }
        } else {
            print("Failed to get the lock folder url")
            return false
        }
    }
    
    static func setup(fetchingNewLocks: Bool) {
        print("setting up locks")
        // fetch new locks if needed
        if fetchingNewLocks == true {
            fetchIncludedLocks()
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
    
    // get the a folder of locks
    static func getLockFolder(lockName: String, isCustom: Bool) -> URL? {
        do {
            if isCustom {
                // get the folder of a lock in custom locks
            } else {
                // get the folder of a lock in included locks
                let newURL: URL = getLocksDirectory()!.appendingPathComponent(lockName)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
                }
                return newURL
            }
        } catch {
            print("An error occurred getting/making the " + lockName + " lock directory")
        }
        return nil
    }
    
    // fetch included lock files
    static func fetchIncludedLocks() {
        // get the included lock names
        let url: URL? = URL(string: "https://raw.githubusercontent.com/leminlimez/Cowabunga/main/IncludedLocks/LockNames.json")
        if url != nil {
            // get the data of the file
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data else {
                    print("No data to decode")
                    return
                }
                guard let locksFileData = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    print("Couldn't decode json data")
                    return
                }
                
                // function to fetch update files
                func fetchFiles(lockFileName: String, newFolder: URL, lockFileVersion: Int) {
                    // fetch the files and add it to path
                    for i in 1 ... 40 {
                        let imageURL: URL? = URL(string: "https://raw.githubusercontent.com/leminlimez/Cowabunga/main/IncludedLocks/" + lockFileName + "/trollformation" + String(i) + ".png")
                        if imageURL != nil {
                            let lock_task = URLSession.shared.dataTask(with: imageURL!) { image_data, image_response, image_error in
                                if image_data != nil {
                                    // write the image file
                                    do {
                                        try image_data!.write(to: newFolder.appendingPathComponent("trollformation" + String(i) + ".png"))
                                    } catch {
                                        print("Error writing included lock data to directory")
                                    }
                                } else {
                                    print("No lock data")
                                }
                            }
                            lock_task.resume()
                        }
                    }
                    
                    // write the plist with the version
                    let plistURL: URL = newFolder.appendingPathComponent(lockFileName + ".plist")
                    let plist: [String: Int] = [
                        "version": lockFileVersion
                    ]
                    do {
                        let newData = try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                        try newData.write(to: plistURL)
                    } catch {
                        print("Error creating the version plist!")
                    }
                }
                
                // check if all the files exist and are updated
                if  let locksFileData = locksFileData as? Dictionary<String, AnyObject>, let lockFiles = locksFileData["lock_files"] as? [[String: Any]] {
                    
                    for lockFile in lockFiles {
                        do {
                            let lockFileName: String = lockFile["name"] as! String
                            let lockFileVersion: Int = lockFile["version"] as! Int
                            let isBeta: String? = lockFile["isBeta"] as? String
                            let newFolder: URL? = getLockFolder(lockName: lockFileName, isCustom: false)
                            
                            if !FileManager.default.fileExists(atPath: newFolder!.path + "/" + lockFileName + ".plist") && (isBeta == nil || testingLocks == true) {
                                fetchFiles(lockFileName: lockFileName, newFolder: newFolder!, lockFileVersion: lockFileVersion)
                            } else if FileManager.default.fileExists(atPath: newFolder!.path + "/" + lockFileName + ".plist") && (isBeta == nil || testingLocks == true) {
                                // get the current version
                                do {
                                    let plistData = try Data(contentsOf: newFolder!.appendingPathComponent(lockFileName + ".plist"))
                                    // open plist
                                    let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Int]
                                    if plist["version"] != nil && plist["version"]! < lockFileVersion {
                                        // update the file
                                        fetchFiles(lockFileName: lockFileName, newFolder: newFolder!, lockFileVersion: lockFileVersion)
                                    }
                                } catch {
                                    print("Error while trying to update files: " + error.localizedDescription)
                                }
                            } else if FileManager.default.fileExists(atPath: newFolder!.path + "/" + lockFileName + ".plist") && (isBeta != nil || testingLocks == false) {
                                // delete since it is in beta and user is not part of beta channel
                                do {
                                    try FileManager.default.removeItem(at: newFolder!)
                                } catch {
                                    print("There was an error trying to remove the lock files: " + error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
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
                       <contents type=\"CGImage\" src=\"trolling1x\"/>\
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
             <value type=\"CGImage\" src=\"trolling40x\"/>\
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
                     <real value=\"0.9\"/>\
               </keyTimes>\
               <values>\
                     <CGImage src=\"trolling1x\"/>\
                     <CGImage src=\"trolling2x\"/>\
                     <CGImage src=\"trolling3x\"/>\
                     <CGImage src=\"trolling4x\"/>\
                     <CGImage src=\"trolling5x\"/>\
                     <CGImage src=\"trolling6x\"/>\
                     <CGImage src=\"trolling7x\"/>\
                     <CGImage src=\"trolling8x\"/>\
                     <CGImage src=\"trolling9x\"/>\
                     <CGImage src=\"trolling10x\"/>\
                     <CGImage src=\"trolling11x\"/>\
                     <CGImage src=\"trolling12x\"/>\
                     <CGImage src=\"trolling13x\"/>\
                     <CGImage src=\"trolling14x\"/>\
                     <CGImage src=\"trolling15x\"/>\
                     <CGImage src=\"trolling16x\"/>\
                     <CGImage src=\"trolling17x\"/>\
                     <CGImage src=\"trolling18x\"/>\
                     <CGImage src=\"trolling19x\"/>\
                     <CGImage src=\"trolling20x\"/>\
                     <CGImage src=\"trolling21x\"/>\
                     <CGImage src=\"trolling22x\"/>\
                     <CGImage src=\"trolling23x\"/>\
                     <CGImage src=\"trolling24x\"/>\
                     <CGImage src=\"trolling25x\"/>\
                     <CGImage src=\"trolling26x\"/>\
                     <CGImage src=\"trolling27x\"/>\
                     <CGImage src=\"trolling28x\"/>\
                     <CGImage src=\"trolling29x\"/>\
                     <CGImage src=\"trolling30x\"/>\
                     <CGImage src=\"trolling31x\"/>\
                     <CGImage src=\"trolling32x\"/>\
                     <CGImage src=\"trolling33x\"/>\
                     <CGImage src=\"trolling34x\"/>\
                     <CGImage src=\"trolling35x\"/>\
                     <CGImage src=\"trolling36x\"/>\
                     <CGImage src=\"trolling37x\"/>\
                     <CGImage src=\"trolling38x\"/>\
                     <CGImage src=\"trolling39x\"/>\
                     <CGImage src=\"trolling40x\"/>\
               </values>\
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
