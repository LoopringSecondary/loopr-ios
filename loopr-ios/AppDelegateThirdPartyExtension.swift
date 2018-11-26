//
//  AppDelegateThirdPartyExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 11/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    //  微信回调
    func onResp(_ resp: BaseResp!) {
        //  微信登录回调
        if resp.isKind(of: SendAuthResp.self) {
            let authResp = resp as! SendAuthResp
            if authResp.errCode == 0, let code = authResp.code, let appid = getWechatAppId(), let secret = getWechatAppSecret() {
                let parameters = ["appid": appid, "secret": secret, "code": code, "grant_type": "authorization_code"]
                Request.get("https://api.weixin.qq.com/sns/oauth2/access_token", parameters: parameters) { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    let json = JSON(data)
                    let accessToken = json["access_token"].stringValue
                    let openID = json["openid"].stringValue
                    UserDefaults.standard.set(openID, forKey: UserDefaultsKeys.openID.rawValue)
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.thirdParty.rawValue)
                    UserDefaults.standard.synchronize()
                    self.synchronizeWithCloud(openID: openID, accessToken: accessToken)
                }
            }
        }
    }
    
    private func synchronizeWithCloud(openID: String, accessToken: String) {
        var configuration = JSON()
        configuration["userId"] = JSON(openID)
        configuration["language"] = JSON(SettingDataManager.shared.getCurrentLanguage().name)
        configuration["currency"] = JSON(SettingDataManager.shared.getCurrentCurrency().name)
        AppServiceUserManager.shared.getUserConfig(completion: { (config, _) in
            if config == nil {
                AppServiceUserManager.shared.updateUserConfig(openID: openID, config: configuration)
            } else if let configString = config?.rawString() {
                configuration = JSON.init(parseJSON: configString)
                
                // TODO: If the www.loopring.mobi/api/v1/users doesn't use a config with language or currency,
                // This part will crash.
                _ = SetLanguage(configuration["language"].stringValue)
                SettingDataManager.shared.setCurrentCurrency(Currency(name: configuration["currency"].stringValue))
            }
            self.wechatLoginByRequestForUserInfo(openID: openID, accessToken: accessToken)
        })
    }
    
    // This should not be in synchronizeWithCloud
    func wechatLoginByRequestForUserInfo(openID: String, accessToken: String) {
        // 获取用户信息
        let parameters = ["access_token": accessToken, "openid": openID]
        Request.get("https://api.weixin.qq.com/sns/oauth2/access_token", parameters: parameters) { _, _, error in
            guard error == nil else { return }
            DispatchQueue.main.async {
                if AppWalletDataManager.shared.getWallets().isEmpty {
                    self.window?.rootViewController = SetupNavigationController(nibName: nil, bundle: nil)
                } else {
                    self.window?.rootViewController = MainTabController.instantiate()
                }
            }
        }
    }
    
    // Put keys.plist next to info.plist in Xcode.
    func hasKeysPlist() -> Bool {
        if Bundle.main.path(forResource: "keys", ofType: "plist") != nil {
            return true
        } else {
            return false
        }
    }
    
    func getWechatAppId() -> String? {
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let wechatAppId = dict["wechatAppId"] as? String
            return wechatAppId
        }
        return nil
    }
    
    func getWechatAppSecret() -> String? {
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let wechatAppId = dict["wechatAppSecret"] as? String
            return wechatAppId
        }
        return nil
    }
    
}
