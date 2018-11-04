//
//  AppDelegateNotificationExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
