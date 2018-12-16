//
//  PushNotificationSettingManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Crashlytics

class PushNotificationSettingManager {
    
    static let shared = PushNotificationSettingManager()
    
    private init() {
        
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            Answers.logCustomEvent(withName: "Push Notifications Permission v1",
                                   customAttributes: [
                                   "granted": granted])
            /*
            guard granted else {
                return
            }
            */
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

}
