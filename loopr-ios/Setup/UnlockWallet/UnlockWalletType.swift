//
//  UnlockWalletType.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum UnlockWalletType: CustomStringConvertible {
    
    case mnemonic
    case keystore
    case privateKey
    
    var description: String {
        switch self {
        case .mnemonic: return NSLocalizedString("Mnemonic", comment: "")
        case .keystore: return NSLocalizedString("Keystore", comment: "")
        case .privateKey: return NSLocalizedString("Private Key", comment: "")
        }
    }

}
