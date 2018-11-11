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
    
    let BAK_URL = "https://www.loopring.mobi/api/v1/users"

    typealias CompletionHandler = (_ data: JSON?, _ error: Error?) -> Void

    private init() {
        
    }

    // Endpoint /api/v1/users
    func getUserConfig(completion: @escaping CompletionHandler) {
        // Always get openid from UserDefaultsKeys
        if let openID = UserDefaults.standard.string(forKey: UserDefaultsKeys.openID.rawValue) {
            let parameters = ["account_token": openID]
            Request.get(BAK_URL, parameters: parameters) { data, _, error in
                guard let data = data, error == nil else {
                    print("Endpoint /api/v1/users GET failed")
                    completion(nil, NSError())
                    return
                }
                
                // Parse response
                let json = JSON(data)
                let messageString = json["message"].string ?? ""
                if let dataFromString = messageString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do {
                        let json = try JSON(data: dataFromString)
                        let config = json["config"].stringValue
                        
                        let configString = JSON(config).string ?? ""
                        if let configData = configString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                            let configJson = try JSON(data: configData)
                            
                            // Parse successfully.
                            completion(configJson, nil)
                        }
                    } catch {
                        
                    }
                }
                
                // Parse fails
                completion(nil, NSError())
            }
        } else {
            completion(nil, NSError())
        }
    }
    
    // use POST to update user config.
    func updateUserConfig(openID: String, config: JSON, completion: @escaping CompletionHandler) {
        var body = JSON()
        body["account_token"] = JSON(openID)
        body["config"] = config
        
        Request.post(body: body, url: URL.init(string: BAK_URL)!) { data, _, error in
            guard let data = data, error == nil else {
                print("Endpoint /api/v1/users POST failed")
                completion(nil, NSError())
                return
            }
            let json = JSON(data)
            completion(json["config"], nil)
        }
    }
    
    func deleteUserConfig(openID: String, completion: @escaping CompletionHandler) {
        var body = JSON()
        body["account_token"] = JSON(openID)
        Request.delete(body: body, url: URL.init(string: BAK_URL)!) { (data, _, error) in
            guard let data = data, error == nil else { return }
            let json = JSON(data)
            completion(json["config"], nil)
        }
    }
}
