//
//  AudioReplacementData.swift
//  Cowabunga
//
//  Created by lemin on 1/8/23.
//  Audio files by c22dev on 1/12/23
//

import Foundation

// this could have been a json file lol
// yes it could have been

class AudioFiles {
    enum SoundEffect: String, CaseIterable {
        // Device Sounds
        case charging = "Charging"
        case lock = "Lock"
        case lowPower = "Low Power"
        case notification = "Notification"
        
        // Camera Sounds
        case screenshot = "Screenshot"
        case beginRecording = "Begin Recording"
        case endRecording = "End Recording"
        
        // Messages Sounds
        case sentMessage = "Sent Message"
        case receivedMessage = "Received Message"
        case sentMail = "Sent Mail"
        case newMail = "New Mail"
        
        // Payment Sounds
        case paymentSuccess = "Payment Success"
        case paymentFailed = "Payment Failed"
        case paymentReceived = "Payment Received"
        
        // Keyboard Sounds
        case kbKeyClick = "Key Click"
        case kbKeyDel = "Key Delete"
        case kbKeyMod = "Key Modifier"
    }
    
    static var ListOfAudio: [String: [String]] = [:]
    static var testingAudio: Bool = false
    
    static var applyFailedMessage: String = ""
    
    static func getIncludedAudioList() -> [String: [String]]? {
        do {
            let newURL: URL = getIncludedAudioDirectory()!.appendingPathComponent("AudioNames.plist")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                var plist: [String: [String]] = [:]
                // create the plist
                for attachment in SoundEffect.allCases {
                    plist[attachment.rawValue] = ["Default"]
                }
                plist["Version"] = ["0"]
                let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                try newData.write(to: newURL)
                return plist
            } else {
                // get the existing plist
                let plistData = try Data(contentsOf: newURL)
                
                // open plist
                let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: [String]]
                return plist
            }
        } catch {
            print("An error occurred getting/making the audio directory")
        }
        return nil
    }
    
    static func addIncludedAudioFile(audioName: String, attachments: [String]) {
        for attachment in attachments {
            if ListOfAudio[attachment] != nil {
                ListOfAudio[attachment]?.append(audioName)
            } else {
                ListOfAudio[attachment] = [audioName]
            }
        }
        
        // write to the plist
        do {
            let newURL: URL = getIncludedAudioDirectory()!.appendingPathComponent("AudioNames.plist")
            let newData = try PropertyListSerialization.data(fromPropertyList: ListOfAudio, format: .xml, options: 0)
            try newData.write(to: newURL)
        } catch {
            print("error adding the audio to the file")
        }
    }
    
    static func setup(fetchingNewAudio: Bool) {
        print("setting up audio")
        // fetch new audio if needed
        if fetchingNewAudio == true {
            fetchIncludedAudio()
        }
        
        ListOfAudio = getIncludedAudioList()!
    }
    
    static func applyAllAudio() -> Bool {
        var failed: Bool = false
        applyFailedMessage = ""
        for audioOption in SoundEffect.allCases {
            // apply if not default
            let currentAudio: String = UserDefaults.standard.string(forKey: audioOption.rawValue+"_Applied") ?? "Default"
            if currentAudio != "Default" {
                let succeeded = overwriteFile(typeOfFile: OverwritingFileTypes.audio, fileIdentifier: audioOption.rawValue, currentAudio)
                if succeeded {
                    print("successfully applied audio for " + audioOption.rawValue)
                } else {
                    print("failed to apply audio for " + audioOption.rawValue)
                    failed = true
                    if applyFailedMessage != "" {
                        applyFailedMessage += ", "
                    }
                    applyFailedMessage += audioOption.rawValue
                }
            }
        }
        return !failed
    }
    
    static func getNewAudioData(soundName: String) -> Data? {
        if FileManager.default.fileExists(atPath: (getIncludedAudioDirectory()?.appendingPathComponent(soundName+".m4a").path)!) {
            do {
                let newData = try Data(contentsOf: (getIncludedAudioDirectory()?.appendingPathComponent(soundName+".m4a"))!)
                return newData
            } catch {
                print("An error occurred getting the data of the audio")
                return nil
            }
        }
        return nil
    }
    static func getCustomAudioData(soundName: String) -> Data? {
        if (soundName.starts(with: "USR_")) {
            // it is a custom user audio file
            if FileManager.default.fileExists(atPath: URL.documents.path + "/Cowabunga_Audio/" + soundName + ".m4a") {
                // file exists
                do {
                    let audioURL = URL(fileURLWithPath: URL.documents.path + "/Cowabunga_Audio/" + soundName + ".m4a")
                    let audioData = try Data(contentsOf: audioURL)
                    return audioData
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    static func getAudioPath(attachment: String) -> String? {
        if self.audioPaths[attachment] != nil {
            return self.audioPaths[attachment]!
        }
        return nil
    }
    
    // get the user audio file names
    static func getCustomAudio() -> [String] {
        let fm = FileManager.default
        var audioFiles: [String] = []
        let audioDir = getAudioDirectory()
        if audioDir != nil {
            for audioURL in (try? fm.contentsOfDirectory(at: audioDir!, includingPropertiesForKeys: nil)) ?? [] {
                audioFiles.append(audioURL.deletingPathExtension().lastPathComponent)
            }
        }
        return audioFiles
    }
    
    // get the directory of the audio
    static func getAudioDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Cowabunga_Audio")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the audio directory")
        }
        return nil
    }
    
    struct audioFilesData: Codable {
        let files: [audioFilesInfo]
    }
    
    struct audioFilesInfo: Codable {
        let name: String
        let attachments: [String]
    }
    
    // fetch included audio files
    static func fetchIncludedAudio() {
        // get the included audio names
        let url: URL? = URL(string: "https://raw.githubusercontent.com/leminlimez/Cowabunga/main/IncludedAudio/AudioNames.json")
        if url != nil {
            // get the data of the file
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data else {
                    print("No data to decode")
                    return
                }
                guard let audioFileData = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    print("Couldn't decode json data")
                    return
                }
                
                // check if all the files exist
                if  let audioFileData = audioFileData as? Dictionary<String, AnyObject>, let audioFiles = audioFileData["audio_files"] as? [[String: Any]], let includedAudioDirectory: URL = getIncludedAudioDirectory() {
                    
                    if let dc = audioFiles[0] as? [String: [String: String]] {
                        if dc["Version"] != nil && dc["Version"]!["version"] != nil {
                            if ListOfAudio["Version"] == nil || ListOfAudio["Version"]![0].compare(dc["Version"]!["version"]!, options: .numeric) == .orderedAscending {
                                ListOfAudio.removeAll()
                                ListOfAudio["Version"] = [dc["Version"]!["version"]!]
                                do {
                                    try FileManager.default.removeItem(at: getIncludedAudioDirectory()!)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    for audioTitle in audioFiles {
                        let audioFileName: String = audioTitle["name"] as! String
                        if audioFileName == "Version" {
                            continue
                        }
                        let audioFileAttachments: [String] = audioTitle["attachments"] as! [String]
                        let isBeta: String? = audioTitle["isBeta"] as? String
                        if !FileManager.default.fileExists(atPath: includedAudioDirectory.path + "/" + audioFileName + ".m4a") && (isBeta == nil || testingAudio == true) {
                            // fetch the file and add it to path
                            let audioURL: URL? = URL(string: "https://raw.githubusercontent.com/leminlimez/Cowabunga/main/IncludedAudio/" + audioFileName + ".m4a")
                            if audioURL != nil {
                                let audio_task = URLSession.shared.dataTask(with: audioURL!) { audio_data, audio_response, audio_error in
                                    if audio_data != nil {
                                        // write the audio file
                                        do {
                                            addIncludedAudioFile(audioName: audioFileName, attachments: audioFileAttachments)
                                            try audio_data!.write(to: includedAudioDirectory.appendingPathComponent(audioFileName + ".m4a"))
                                        } catch {
                                            print("Error writing included audio data to directory")
                                        }
                                    } else {
                                        print("No audio data")
                                    }
                                }
                                audio_task.resume()
                            }
                        } else if isBeta != nil && testingAudio == false && FileManager.default.fileExists(atPath: includedAudioDirectory.path + "/" + audioFileName + ".m4a") {
                            // delete the file
                            do {
                                try FileManager.default.removeItem(at: includedAudioDirectory.appendingPathComponent(audioFileName+".m4a"))
                            } catch {
                                print("There was an error removing the file")
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    // get the directory of the included audio
    static func getIncludedAudioDirectory() -> URL? {
        do {
            let newURL: URL = URL.documents.appendingPathComponent("Included_Audio")
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            }
            return newURL
        } catch {
            print("An error occurred getting/making the included audio directory: \(error.localizedDescription)")
        }
        return nil
    }
    
    // audio paths
    private static let audioPaths: [String: String] = [
        // Device Sounds Paths
        SoundEffect.charging.rawValue: "UISounds/connect_power.caf",
        SoundEffect.lock.rawValue: "UISounds/lock.caf",
        SoundEffect.lowPower.rawValue: "UISounds/low_power.caf",
        SoundEffect.notification.rawValue: "UISounds/sms-received1.caf",
        
        // Camera Sounds Paths
        SoundEffect.screenshot.rawValue: "UISounds/photoShutter.caf",
        SoundEffect.beginRecording.rawValue: "UISounds/begin_record.caf",
        SoundEffect.endRecording.rawValue: "UISounds/end_record.caf",
        
        // Messages Sounds Paths
        SoundEffect.sentMessage.rawValue: "UISounds/SentMessage.caf",
        SoundEffect.receivedMessage.rawValue: "UISounds/ReceivedMessage.caf",
        SoundEffect.sentMail.rawValue: "UISounds/mail-sent.caf",
        SoundEffect.newMail.rawValue: "UISounds/new-mail.caf",
        
        // Payments Sounds Paths
        SoundEffect.paymentSuccess.rawValue: "UISounds/payment_success.caf",
        SoundEffect.paymentFailed.rawValue: "UISounds/payment_failure.caf",
        SoundEffect.paymentReceived.rawValue: "UISounds/PaymentReceived.caf",
        
        // Keyboard Sounds Paths
        SoundEffect.kbKeyClick.rawValue: "UISounds/keyboard_press_normal.caf",
        SoundEffect.kbKeyDel.rawValue: "UISounds/keyboard_press_delete.caf",
        SoundEffect.kbKeyMod.rawValue: "UISounds/keyboard_press_clear.caf",
    ]
}
