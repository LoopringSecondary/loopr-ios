//
//  SettingsBundleHelper.swift
//  loopr-ios
//
//  Created by yimenglovesai on 4/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class SettingsBundleHelper {

    class func setVersionAndBuildNumber() {
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String

        UserDefaults.standard.set(version, forKey: UserDefaultsKeys.appVersion.rawValue)
        UserDefaults.standard.set(build, forKey: UserDefaultsKeys.appBuildNumber.rawValue)
    }
}
