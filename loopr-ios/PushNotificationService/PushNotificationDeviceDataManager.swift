//
//  PushNotificationDeviceDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Crashlytics

class PushNotificationDeviceDataManager {
    
    static let shared = PushNotificationDeviceDataManager()
    
    private let registerURL = URL(string: "https://www.loopring.mobi/rpc/v1/device/addDevice")!
    private let removeURL = URL(string: "https://www.loopring.mobi/rpc/v1/device/deleteDevice")!
    
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
            body["bundle_identifier"] = JSON(bundleIdentifier)
            body["device_token"] = JSON(deviceToken)
            body["address"] = JSON(address)
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            body["current_installed_version"] = JSON(version)
            body["current_language"] = JSON(SettingDataManager.shared.getCurrentLanguage().name)
            
            // Different certificats for release and debug
            #if RELEASE
                // release only code
                guard bundleIdentifier == "io.upwallet.app" else {
                    return
                }
                body["isReleaseMode"] = true
            #else
                // debug only code
                body["isReleaseMode"] = false
            #endif

            Request.post(body: body, url: registerURL, showFailureBannerNotification: false) { data, _, error in
                guard data != nil, error == nil else {
                    print("error=\(String(describing: error))")
                    Answers.logCustomEvent(withName: "API App Service: PushNotificationDeviceDataManager.register v1",
                                           customAttributes: [
                                           "success": "false",
                                           "hasDeviceToken": "true"])
                    return
                }
                print("success")
                Answers.logCustomEvent(withName: "API App Service: PushNotificationDeviceDataManager.register v1",
                                       customAttributes: [
                                       "success": "true",
                                       "hasDeviceToken": "true"])
            }
        } else {
            Answers.logCustomEvent(withName: "API App Service: PushNotificationDeviceDataManager.register v1",
                                   customAttributes: [
                                    "success": "false",
                                    "hasDeviceToken": "false"])
        }
    }

    func remove(address: String) {
        if let deviceToken = getDeviceToken() {
            let deleteUrl = "https://www.loopring.mobi/api/v1/devices/\(deviceToken)/\(address)"
            var request = URLRequest(url: URL(string: deleteUrl)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "DELETE"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
            }
            task.resume()
        }
    }

}
