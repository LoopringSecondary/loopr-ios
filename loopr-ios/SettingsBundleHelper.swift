//
//  SettingsBundleHelper.swift
//  loopr-ios
//
//  Created by yimenglovesai on 4/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }

    class func setVersionAndBuildNumber() {
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String

        UserDefaults.standard.set(version, forKey: "app_version")
        UserDefaults.standard.set(build, forKey: "build_version")
    }
}
