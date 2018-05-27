//
//  AuthenticationDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class AuthenticationDataManager {

    static let shared = AuthenticationDataManager()

    var hasLogin: Bool = false
    
    private init() {
        
    }
    
    func getPasscodeSetting() -> Bool {
        let passcodeOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.passcodeOn.rawValue)
        return passcodeOn
    }
    
    func setPasscodeSetting(_ newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.passcodeOn.rawValue)
    }

}
