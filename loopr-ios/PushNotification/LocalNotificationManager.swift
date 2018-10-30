//
//  File.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// NOTE:
// LocalNotificationManager is attached to MainTabController,
// which is the base-level view controller in the app.
class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    
    private init() {
        
    }
    
    func publishNotification() {
        NotificationCenter.default.post(name: .publishLocalNotificationToMainTabController, object: nil)
    }

}
