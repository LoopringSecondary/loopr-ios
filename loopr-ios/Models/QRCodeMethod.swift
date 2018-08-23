//
//  SetupWalletMethod.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum QRCodeMethod: String {
    
    case create = "SetupWalletMethod.create"
    case importUsingMnemonic = "SetupWalletMethod.importUsingMnemonic"
    case importUsingKeystore = "SetupWalletMethod.importUsingKeystore"
    case importUsingPrivateKey = "SetupWalletMethod.importUsingPrivateKey"
    case authorization = "Authorization"
    
    var description: String {
        switch self {
        case .create: return LocalizedString("Create", comment: "")
        case .importUsingMnemonic: return LocalizedString("Mnemonic", comment: "")
        case .importUsingKeystore: return LocalizedString("Keystore", comment: "")
        case .importUsingPrivateKey: return LocalizedString("Private Key", comment: "")
        case .authorization: return LocalizedString("Authorization", comment: "")
        }
    }
    
    // The following methods are to choose the type quickly. No computation should be added.
    static func isAddress(content: String) -> Bool {
        return content.isHexAddress()
    }
    
    static func isMnemonicValid(content: String) -> Bool {
        return Mnemonic.isValid(content)
    }
    
    static func isPrivateKey(content: String) -> Bool {
        let keyContent = content.uppercased()
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
    
    static func isP2POrder(content: String) -> Bool {
        if let data = content.data(using: .utf8) {
            let json = JSON(data)
            if json["type"] == "P2P" {
                return true
            }
        }
        return false
    }
    
    static func isKeystore(content: String) -> Bool {
        guard content.range(of: "ciphertext") != nil else {
            return false
        }
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
    
    static func isSubmitOrder(content: String) -> Bool {
        if let data = content.data(using: .utf8) {
            let json = JSON(data)
            if json["type"] == "sign" {
                return true
            }
        }
        return false
    }
    
    static func isLogin(content: String) -> Bool {
        if let data = content.data(using: .utf8) {
            let json = JSON(data)
            if json["type"] == "UUID" {
                return true
            }
        }
        return false
    }
    
    static func isCancelOrder(content: String) -> Bool {
        if let data = content.data(using: .utf8) {
            let json = JSON(data)
            if json["type"] == "cancelOrder" {
                return true
            }
        }
        return false
    }
    
    static func isApprove(content: String) -> Bool {
        if let data = content.data(using: .utf8) {
            let json = JSON(data)
            if json["type"] == "approve" {
                return true
            }
        }
        return false
    }
    
    static func isConvert(content: String) -> Bool {
        if let data = content.data(using: .utf8) {
            let json = JSON(data)
            if json["type"] == "convert" {
                return true
            }
        }
        return false
    }
}
