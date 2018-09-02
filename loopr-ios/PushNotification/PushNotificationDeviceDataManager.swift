//
//  PushNotificationDeviceDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class PushNotificationDeviceDataManager {
    
    static let shared = PushNotificationDeviceDataManager()
    
    private final let APNsUrl = ""
    
    private init() {

    }

    func register() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            
        }
    }

    func remove() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            
        }
    }
}
