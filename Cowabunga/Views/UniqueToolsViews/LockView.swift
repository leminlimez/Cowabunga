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
    
    @State private var currentLock: String = "Default"
    @State private var locksDir = LockManager.getLocksDirectory()
    @State private var isImporting: Bool = false
    
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
                        
                        Image(systemName: "lock.fill")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 30, height: 40)
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
                            print("applying lock")
                            let succeeded = LockManager.applyLock(lockName: lock.title.wrappedValue)
                            if succeeded {
                                UIApplication.shared.alert(title: "Successfully applied lock!", body: "Respring needed to finish applying.")
                            } else {
                                UIApplication.shared.alert(body: "An error occurred while trying to apply the lock.")
                            }
                        }) {
                            Text(lock.title.wrappedValue)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { i in
                        let deletingLockName = locks[i].title
                        print("Deleting: " + deletingLockName)
                        
                        // delete the file
                        do {
                            let url = locksDir!.appendingPathComponent(deletingLockName)
                            try FileManager.default.removeItem(at: url)
                            locks.remove(at: i)
                        } catch {
                            UIApplication.shared.alert(body: "Unable to delete files for lock \"" + deletingLockName + "\"!")
                        }
                    }
                }
            }
        }
        .navigationTitle("Locks")
        .toolbar {
            Button(action: {
                // import a custom lock
                // allow the user to choose the file
                isImporting.toggle()
            }) {
                Image(systemName: "square.and.arrow.down")
            }
        }
        .onAppear {
            currentLock = UserDefaults.standard.string(forKey: "CurrentLock") ?? "Default"
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
                    locks.removeAll(keepingCapacity: true)
                    let numOfSaved = try FileManager.default.contentsOfDirectory(at: locksDir!, includingPropertiesForKeys: nil).count
                    
                    if numOfSaved > 0 {
                        for lock in try FileManager.default.contentsOfDirectory(at: locksDir!, includingPropertiesForKeys: nil) {
                            let lockName: String = lock.lastPathComponent
                            //let lockImage: URL? = lock.appendingPathComponent("preview.png")
                            //if lockName != nil && passcodeImage != nil {
                            let checked: Bool = lockName == currentLock
                            do {
                                let icon = try Data(contentsOf: lock.appendingPathComponent("trollformation1.png"))
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
        .sheet(isPresented: $isImporting) {
            DocumentPicker(
                types: [
                    .folder
                ]) { result in
                    // user chose a file
                    if result.first == nil { UIApplication.shared.alert(body: NSLocalizedString("Couldn't get url of folder. Did you select it?", comment: "")); return }
                    let url: URL = result.first!
                    guard url.startAccessingSecurityScopedResource() else { UIApplication.shared.alert(body: "File permission error"); return }
                    
                    // ask for a name for the lock
                    let alert = UIAlertController(title: NSLocalizedString("Enter Name", comment: ""), message: NSLocalizedString("Choose a name for the lock", comment: ""), preferredStyle: .alert)
                    
                    // bring up the text prompts
                    alert.addTextField { (textField) in
                        // text field for width
                        textField.placeholder = NSLocalizedString("Name", comment: "")
                        textField.text = url.deletingPathExtension().lastPathComponent
                    }
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { (action) in
                        // set the name and add the file
                        if alert.textFields?[0].text != nil {
                            // check if it is a valid name
                            let validChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890._")
                            var fileName: String = (alert.textFields?[0].text ?? "Unnamed").filter{validChars.contains($0)}
                            if fileName == "" {
                                // set to unnamed
                                fileName = "Unnamed"
                            }
                            // save the folder
                            do {
                                let fileImportName: String = fileName
                                let icon = try LockManager.addImportedLock(lockName: fileImportName, url: url)
                                let uiIcon = UIImage(data: icon)
                                locks.append(Lock.init(title: fileImportName, icon: uiIcon))
                                UIApplication.shared.alert(title: NSLocalizedString("Success!", comment: ""), body: NSLocalizedString("The imported lock was successfully saved.", comment: "Saving imported lock"))
                            } catch {
                                print(error.localizedDescription)
                                UIApplication.shared.alert(title: NSLocalizedString("Unable to save imported lock!", comment: "Failed to import lock"), body: error.localizedDescription)
                            }
                        } else {
                            print("alert textfield is nil!")
                            UIApplication.shared.alert(body: "Unexpected error with textfield")
                        }
                        url.stopAccessingSecurityScopedResource()
                    })
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
                        // cancel the process
                        url.stopAccessingSecurityScopedResource()
                    })
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
    }
}
