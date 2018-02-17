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
        case .mnemonic: return "Mnemonic"
        case .keystore: return "Keystore"
        case .privateKey: return "Private Key"
        }
    }

}
