//
//  FeatureConfigDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 12/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class FeatureConfigDataManager {
    
    static let shared = FeatureConfigDataManager()
    
    let minValue: Double = 30
    private var showTradingFeature: Bool = false
    
    private init() {
        
    }
    
    // TODO: improve this feature.
    func getShowTradingFeature() -> Bool {
        guard Production.isAppStoreVersion() else {
            return true
        }
        
        let version = "1.3.1"
        let currentBuildVersion = AppServiceUpdateManager.shared.getBuildVersion()
        if version.compare(currentBuildVersion, options: .numeric) == .orderedDescending {
            // If version is less than 1.3.1, always return true
            return true
        }
        
        return showTradingFeature
        /*
        let defaults = UserDefaults.standard
        // If the value is absent or can't be converted to a BOOL, NO will be returned.
        let showTradingFeature = defaults.bool(forKey: UserDefaultsKeys.showTradingFeature.rawValue)
        return showTradingFeature
        */
    }
    
    func setShowTradingFeature(_ newValue: Bool) {
        guard Production.isAppStoreVersion() else {
            return
        }

        showTradingFeature = newValue
        /*
        let defaults = UserDefaults.standard
        defaults.set(newValue, forKey: UserDefaultsKeys.showSmallAssets.rawValue)
        */
    }

}
