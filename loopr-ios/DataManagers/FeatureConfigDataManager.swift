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
    
    private init() {
        
    }
    
    // TODO: improve this feature.
    func getShowTradingFeature() -> Bool {
        let version = "1.3.1"
        let currentBuildVersion = AppServiceUpdateManager.shared.getBuildVersion()
        if version.compare(currentBuildVersion, options: .numeric) == .orderedDescending {
            return true
        }
        
        let defaults = UserDefaults.standard
        // If the value is absent or can't be converted to a BOOL, NO will be returned.
        let showTradingFeature = defaults.bool(forKey: UserDefaultsKeys.showTradingFeature.rawValue)
        return showTradingFeature
    }
    
    func setShowTradingFeature(_ newValue: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(newValue, forKey: UserDefaultsKeys.showSmallAssets.rawValue)
    }

}
