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
    func getUserConfig(openID: String, completion: @escaping CompletionHandler) {
        // Example
        let parameters = ["account_token": openID]
        Request.get(BAK_URL, parameters: parameters) { data, _, error in
            guard let data = data, error == nil else { return }
            let json = JSON(data)
            completion(json["message"]["config"], nil)
        }
    }
    
    // use POST to update user config.
    func updateUserConfig(openID: String, config: JSON, completion: @escaping CompletionHandler) {
        
        // Example to update the user config.
        var body = JSON()
        body["account_token"] = JSON(openID)
        body["config"] = config
        
        Request.post(body: body, url: URL.init(string: BAK_URL)!) { data, _, error in
            guard let data = data, error == nil else { return }
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
