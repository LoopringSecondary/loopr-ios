//
//  SetupDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class SetupDataManager {
    
    static let shared = SetupDataManager()
    
    var hasPresented: Bool = false
    
    private init() {
        
    }
    
    // Has been setup is different than an empty list of wallet.
    // It could happen that users disable all wallets.
    func hasBeenSetup() -> Bool {
        let defaults = UserDefaults.standard
        let hasBeenSetup = defaults.bool(forKey: UserDefaultsKeys.hasBeenSetup.rawValue)
        return hasBeenSetup
    }
    
    func completeSetup() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: UserDefaultsKeys.hasBeenSetup.rawValue)
    }
}
