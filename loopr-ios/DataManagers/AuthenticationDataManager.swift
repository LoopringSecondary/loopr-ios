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
    
    var isAuthenticating: Bool = false
    var hasLogin: Bool = false
    
    private init() {
        
    }
    
    public func devicePasscodeEnabled() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    func getPasscodeSetting() -> Bool {
        guard BiometricType.get() != .none else {
            return false
        }
        let passcodeOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.passcodeOn.rawValue)
        return passcodeOn
    }
    
    func setPasscodeSetting(_ newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.passcodeOn.rawValue)
    }
    
    func authenticate(reason: String, completion: @escaping (_ error: Error?) -> Void) {
        isAuthenticating = true
        let context = LAContext()
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        AuthenticationDataManager.shared.hasLogin = true
                        self.isAuthenticating = false
                        completion(nil)
                    } else {
                        self.isAuthenticating = false
                        completion(error)
                    }
                }
            }
        } else {
            print(authError.debugDescription)
            // Could not start authentication. So disable touch id or face id.
            setPasscodeSetting(false)
            AuthenticationDataManager.shared.hasLogin = true
            DispatchQueue.main.async {
                self.isAuthenticating = false
                completion(nil)
            }
        }
    }
}
