//
//  AppDelegate.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

import SwiftUI
import MacDirtyCowSwift

extension UNNotificationCategory
{
    static let clipboardReaderIdentifier = "CowabungaTweaksApplication"
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(defaults: createDefaults())
        if UserDefaults.standard.bool(forKey: "BackgroundApply") == true {
            setBGApplyOptions()
            ApplicationMonitor.shared.start()
            
            self.registerForNotifications()
        }
        
        return true
    }
    
    func createDefaults() -> [String: Any] {
        var defaults: [String: Any] = [
            "AutoFetchAudio": true,
            "AutoFetchLocks": true,
            "LockPrefs": LockManager.deviceLockPath[UIDevice().machineName] ?? LockManager.globalLockPaths[0],
            "SelectedFont": "None",
            "BackgroundUpdateInterval": 600.0,
            "catalogIconTheming": true
        ]
        for bgOption in BackgroundFileUpdaterController.shared.BackgroundOptions {
            defaults[bgOption.key + "_BGApply"] = true
        }
        return defaults
    }
    
    func setBGApplyOptions() {
        for (i, bgOption) in BackgroundFileUpdaterController.shared.BackgroundOptions.enumerated() {
            if !UserDefaults.standard.bool(forKey: bgOption.key + "_BGApply") {
                BackgroundFileUpdaterController.shared.BackgroundOptions[i].enabled = false
            }
        }
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        MDC.isMDCSafe = false
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    private func registerForNotifications() {
        let category = UNNotificationCategory(identifier: UNNotificationCategory.clipboardReaderIdentifier, actions: [], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.notification.request.content.categoryIdentifier == UNNotificationCategory.clipboardReaderIdentifier else { return }
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        print(response)
    }
}
