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
    
    private final let APNsUrl = "http://app-service.bdgt26mqwd.ap-northeast-1.elasticbeanstalk.com/api/v1/devices"
    
    private init() {

    }
    
    func setDeviceToken(_ deviceToken: String) {
        let currentDeviceToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceToken.rawValue) ?? ""
        UserDefaults.standard.set(deviceToken, forKey: UserDefaultsKeys.deviceToken.rawValue)
        if currentDeviceToken != deviceToken {
            // TODO: improve this part
            for appWallet in AppWalletDataManager.shared.getWallets() {
                register(address: appWallet.address)
            }
        }
    }

    func getDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceToken.rawValue)
    }

    func register(address: String) {
        // If we can get the device token, it means users enable push notifications
        if let bundleIdentifier = Bundle.main.bundleIdentifier, let deviceToken = getDeviceToken() {
            var body: JSON = JSON()
            body["bundleIdentifier"] = JSON(bundleIdentifier)
            body["deviceToken"] = JSON(deviceToken)
            body["address"] = JSON(address)
            
            // Different certificats for release and debug
            #if RELEASE
                // release only code
                body["isReleaseMode"] = true
            #else
                // debug only code
                body["isReleaseMode"] = false
            #endif

            Request.send(body: body, url: URL(string: APNsUrl)!) { data, _, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                print("success")
            }
        }
    }

    // TODO
    func remove(address: String) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            
        }
    }

}
