//
//  AuthenticationDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import LocalAuthentication

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
    
    func authenticate(completion: @escaping (_ error: Error?) -> Void) {
        let context = LAContext()
        let reason = NSLocalizedString("Authenticate to access your wallet", comment: "")
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                if success {
                    AuthenticationDataManager.shared.hasLogin = true
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        } else {
            completion(authError)
        }
    }
}
