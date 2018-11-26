//
//  AppServiceUserManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class AppServiceUserManager {
    
    static let shared = AppServiceUserManager()
    
    let BAK_URL = "https://www.loopring.mobi/rpc/v1/user"
    
    let GET_URL, ADD_URL, DEL_URL: String

    typealias CompletionHandler = (_ data: JSON?, _ error: Error?) -> Void

    private init() {
        GET_URL = BAK_URL + "getUser"
        ADD_URL = BAK_URL + "addUser"
        DEL_URL = BAK_URL + "deleteUser"
    }

    // Endpoint /api/v1/users
    func getUserConfig(completion: @escaping CompletionHandler) {
        // Always get openid from UserDefaultsKeys
        if let openID = UserDefaults.standard.string(forKey: UserDefaultsKeys.openID.rawValue) {
            let parameters = ["account_token": openID]
            Request.get(GET_URL, parameters: parameters) { data, _, error in
                guard let data = data, error == nil else {
                    print("Endpoint /rpc/v1/user GET failed")
                    completion(nil, NSError())
                    return
                }
                do {
                    // Parse response
                    let json = JSON(data)
                    if json["success"].boolValue {
                        if let configString = json["message"]["config"].string,
                           let configData = configString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                           let configJson = try JSON(data: configData)
                            completion(configJson, nil)
                        }
                    } else {
                        completion(nil, NSError())
                    }
                } catch {
                    
                }
            }
        } else {
            completion(nil, NSError())
        }
    }
    
    func updateUserConfigWithUserDefaults() {
        var config = JSON()
        if let openID = UserDefaults.standard.string(forKey: UserDefaultsKeys.openID.rawValue) {
            if !openID.isEmpty {
                config["userId"] = JSON(openID)
                config["currency"] = JSON(SettingDataManager.shared.getCurrentCurrency().name)
                print("Post: " + SettingDataManager.shared.getCurrentCurrency().name)
                config["language"] = JSON(SettingDataManager.shared.getCurrentLanguage().name)
                AppServiceUserManager.shared.updateUserConfig(openID: openID, config: config)
            }
        }
    }
    
    // use POST to update user config.
    func updateUserConfig(openID: String, config: JSON) {
        var body = JSON()
        body["account_token"] = JSON(openID)
        let configString = config.rawString(.utf8, options: .init(rawValue: 0)) ?? ""
        body["config"] = JSON(configString)
        Request.post(body: body, url: URL.init(string: ADD_URL)!) { _, _, error in
            guard error == nil else {
                print("Endpoint /rpc/v1/user POST failed")
                return
            }
        }
    }
    
    func deleteUserConfig(openID: String) {
        let parameters = ["account_token": openID]
        Request.delete(DEL_URL, parameters: parameters) { (_, _, error) in
            guard error == nil else {
                print("Endpoint /rpc/v1/user DELETE failed")
                return
            }
        }
    }
}
