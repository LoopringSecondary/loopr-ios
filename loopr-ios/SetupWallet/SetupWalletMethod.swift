//
//  SetupWalletMethod.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum SetupWalletMethod: String, CustomStringConvertible {

    case create = "SetupWalletMethod.create"
    case importUsingMnemonic = "SetupWalletMethod.importUsingMnemonic"
    case importUsingKeystore = "SetupWalletMethod.importUsingKeystore"
    case importUsingPrivateKey = "SetupWalletMethod.importUsingPrivateKey"

    var description: String {
        switch self {
        case .create: return "Create"
        case .importUsingMnemonic: return "Mnemonics"
        case .importUsingKeystore: return "Keystore"
        case .importUsingPrivateKey: return "Private Key"
        }
    }
}
