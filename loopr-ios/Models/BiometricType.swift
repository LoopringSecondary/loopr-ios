//
//  BiometricType.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/27/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import LocalAuthentication

enum BiometricType: CustomStringConvertible {

    case none
    case touchID
    case faceID
    
    var description: String {
        switch self {
        case .none: return "None"
        case .touchID: return LocalizedString("Touch ID", comment: "")
        case .faceID: return LocalizedString("Face ID", comment: "")
        }
    }

    static func get() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch authContext.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }

}

