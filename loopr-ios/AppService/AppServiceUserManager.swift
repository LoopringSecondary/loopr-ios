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

    private init() {
        
    }

    // Endpoint /api/v1/users
    // Not used in the version 0.9.16
    private func getUserConfig(completion: @escaping (_ shouldDisplayUpdateNotification: Bool) -> Void) {
        // Example
        let account_token = "1234567"
        let url = URL(string: "https://www.loopring.mobi/api/v1/users?account_token=\(account_token)")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let json = JSON(data)
            let language = json["language"].string
            let currency = json["currency"].string
            print("language: \(String(describing: language))")
            print("currency: \(String(describing: currency))")
            completion(true)
        }
        task.resume()
    }
    
    // use POST to update user config.
    func updateUserConfig(completion: @escaping (_ shouldDisplayUpdateNotification: Bool) -> Void) {
        let openid = UserDefaults.standard.string(forKey: "openid") ?? ""

        // Avoid nil nor empty string
        guard openid != "" else {
            completion(false)
            return
        }

        // Example to update the user config.
        var body = JSON()
        body["account_token"] = JSON(openid)
        body["language"] = JSON(SettingDataManager.shared.getCurrentLanguage().name)
        body["currency"] = JSON(SettingDataManager.shared.getCurrentCurrency().name)
        body["lrc_fee_ratio"] = JSON(SettingDataManager.shared.getLrcFeeRatio())

        var request = URLRequest(url: URL(string: "https://www.loopring.mobi/api/v1/users")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            try request.httpBody = body.rawData()
        } catch {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            completion(false)
        }
        task.resume()
    }

}
