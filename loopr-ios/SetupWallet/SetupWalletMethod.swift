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
    
    // The following methods are to choose the type quickly. No computation should be added.
    static func isMnemonicValid(mnemonic: String) -> Bool {
        return Mnemonic.isValid(mnemonic)
    }
    
    static func isPrivateKey(key: String) -> Bool {
        let keyContent = key.uppercased()
        if keyContent.count != 64 {
            return false
        }
        for ch in keyContent {
            if (ch >= "0" && ch <= "9") || (ch >= "A" && ch <= "F") {
                continue
            }
            return false
        }
        return true
    }
    
    static func isKeystore(content: String) -> Bool {
        let jsonData = content.data(using: String.Encoding.utf8)
        if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!, options: []) {
            if JSONSerialization.isValidJSONObject(jsonObject) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
