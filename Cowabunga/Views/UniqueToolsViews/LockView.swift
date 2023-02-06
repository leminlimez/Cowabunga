//
//  LockView.swift
//  Cowabunga
//
//  Created by lemin on 1/27/23.
//
// Credit to Haxi0 for original TrollLock

import Foundation
import SwiftUI

struct LockView: View {
    struct Lock: Identifiable {
        var id = UUID()
        var title: String
        var icon: UIImage?
        var checked: Bool = false
    }
    
    @State var defaultLock = Lock.init(title: "Default")
    @State var locks: [Lock] = [
    ]
    
    @State private var currentLock: String = UserDefaults.standard.string(forKey: "CurrentLock") ?? "Default"
    @State private var locksDir = LockManager.getLocksDirectory()
    
    @State private var isImporting = false
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .foregroundColor(.blue)
                        .opacity(defaultLock.checked ? 1: 0)
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.black)
                            .cornerRadius(6, corners: .topLeft)
                            .cornerRadius(6, corners: .topRight)
                            .cornerRadius(6, corners: .bottomLeft)
                            .cornerRadius(6, corners: .bottomRight)
                        
                        Image(systemName: "lock.open.fill")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        for (i, lock) in locks.enumerated() {
                            if lock.title == currentLock {
                                locks[i].checked = false
                                break
                            }
                        }
                        defaultLock.checked = true
                        currentLock = "Default"
                        UserDefaults.standard.set("Default", forKey: "CurrentLock")
                    }) {
                        Text(defaultLock.title)
                    }
                }
                
                ForEach($locks) { lock in
                    HStack {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .foregroundColor(.blue)
                            .opacity(lock.checked.wrappedValue ? 1: 0)
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                                .cornerRadius(6, corners: .topLeft)
                                .cornerRadius(6, corners: .topRight)
                                .cornerRadius(6, corners: .bottomLeft)
                                .cornerRadius(6, corners: .bottomRight)
                            
                            Image(uiImage: lock.icon.wrappedValue!)
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            if currentLock == "Default" {
                                defaultLock.checked = false
                            } else {
                                for (i, L) in locks.enumerated() {
                                    if L.title == currentLock {
                                        locks[i].checked = false
                                    } else if L.title == lock.title.wrappedValue {
                                        locks[i].checked = true
                                    }
                                }
                            }
                            lock.checked.wrappedValue = true
                            currentLock = lock.title.wrappedValue
                            UserDefaults.standard.set(lock.title.wrappedValue, forKey: "CurrentLock")
                            let lockType: String = LockManager.getLockType()
                            print("applying lock")
                            if lockType != "" {
                                let succeeded = LockManager.applyLock(lockName: lock.title.wrappedValue, lockType: lockType)
                                if succeeded {
                                    UIApplication.shared.alert(title: "Successfully applied lock!", body: "Respring needed to finish applying.")
                                } else {
                                    UIApplication.shared.alert(body: "An error occurred while trying to apply the lock.")
                                }
                            } else {
                                // just apply all of them lol
                                var succeeded: Bool = true
                                for (_, lockPath) in LockManager.globalLockPaths.enumerated() {
                                    succeeded = succeeded && LockManager.applyLock(lockName: lock.title.wrappedValue, lockType: lockPath)
                                }
                                if succeeded {
                                    UIApplication.shared.alert(title: "Successfully applied lock!", body: "Respring needed to finish applying.")
                                } else {
                                    UIApplication.shared.alert(body: "An error occurred while trying to apply the lock.")
                                }
                            }
                        }) {
                            Text(lock.title.wrappedValue.replacingOccurrences(of: "_", with: " "))
                        }
                    }
                }
            }
        }
        .toolbar {
            Button(action: {
                // import a custom audio
                // allow the user to choose the file
                isImporting.toggle()
            }, label: {
                Image(systemName: "square.and.arrow.down")
            })
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            // user chose a file
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of folder. Did you select it?"); return }
            guard url.startAccessingSecurityScopedResource() else { UIApplication.shared.alert(body: "File permission error"); return }
            
            // ask for a name for the lock
            let alert = UIAlertController(title: "Enter Name", message: "Choose a name for the lock", preferredStyle: .alert)
            
            // bring up the text prompts
            alert.addTextField { (textField) in
                // text field for width
                textField.placeholder = "Name"
                textField.text = url.deletingPathExtension().lastPathComponent
            }
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
                // set the name and add the file
                if alert.textFields?[0].text != nil {
                    // check if it is a valid name
                    let validChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890.")
                    var fileName: String = (alert.textFields?[0].text ?? "Unnamed").filter{validChars.contains($0)}
                    if fileName == "" {
                        // set to unnamed
                        fileName = "Unnamed"
                    }
                    // save the folder
                    do {
                        let fileImportName: String = fileName.replacingOccurrences(of: " ", with: "_")
                        let icon = try LockManager.addImportedLock(lockName: fileImportName, url: url)
                        let uiIcon = UIImage(data: icon)
                        locks.append(Lock.init(title: fileImportName, icon: uiIcon))
                        UIApplication.shared.alert(title: "Success!", body: "The imported lock was successfully saved.")
                    } catch {
                        print(error.localizedDescription)
                        UIApplication.shared.alert(title: "Unable to save imported lock!", body: error.localizedDescription)
                    }
                } else {
                    print("alert textfield is nil!")
                    UIApplication.shared.alert(body: "Unexpected error with textfield")
                }
                url.stopAccessingSecurityScopedResource()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                // cancel the process
                url.stopAccessingSecurityScopedResource()
            })
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        .onAppear {
            if currentLock == "Default" {
                defaultLock.checked = true
            } else {
                for (i, lock) in locks.enumerated() {
                    if lock.title == currentLock {
                        locks[i].checked = true
                        break
                    }
                }
            }
            
            do {
                if locksDir != nil {
                    let numOfSaved = try FileManager.default.contentsOfDirectory(at: locksDir!, includingPropertiesForKeys: nil).count
                    
                    if numOfSaved > 0 {
                        for lock in try FileManager.default.contentsOfDirectory(at: locksDir!, includingPropertiesForKeys: nil) {
                            let lockName: String = lock.lastPathComponent
                            //let lockImage: URL? = lock.appendingPathComponent("preview.png")
                            //if lockName != nil && passcodeImage != nil {
                            let checked: Bool = lockName == currentLock
                            do {
                                let icon = try Data(contentsOf: lock.appendingPathComponent("trollformation40.png"))
                                let uiIcon = UIImage(data: icon)
                                locks.append(Lock.init(title: lockName, icon: uiIcon, checked: checked))
                            } catch {
                                print(error.localizedDescription)
                            }
                                /*do {
                                    let imgData = try Data(contentsOf: passcodeImage!)
                                    let uiImg = UIImage(data: imgData)
                                    if uiImg != nil {
                                        savedPasscodesList.append(PasscodeFile.init(passcodeName: passcodeName, passcodeImage: uiImg!, passcodeFile: passcodeURL!))
                                    }
                                } catch {
                                    print("Error getting image data: \(error.localizedDescription)")
                                    continue
                                }*/
                            //}
                        }
                    }
                }
            } catch {
                print("Error getting contents of directory")
            }
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
    }
}
