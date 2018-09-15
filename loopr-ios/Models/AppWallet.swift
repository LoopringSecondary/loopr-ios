//
//  Wallet.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

class AppWallet: NSObject, NSCoding {
    
    final let setupWalletMethod: QRCodeMethod
    
    final let address: String
    
    // The password used to get the address and the private key
    // when users use mnemonics and keystore.
    // At the same time, generating a keystore requires password.
    // However, importing a wallet using private key doesn't require password.
    // Use a default password
    // At this usecase, users need to enter a password when exporting keystore
    private final var password: String
    
    final var mnemonics: [String]
    private final let keystoreString: String
    
    // Only used when the wallet is imported using a private key
    private final let keystorePassword: String = "123456"
    
    // The wallet name in the app. Users can update later.
    var name: String
    
    // If a wallet is created in the app and the user skip the verification,
    // isVerified is false
    var isVerified: Bool

    // A token is added to tokenList when
    // 1. the amount is not zero in the device one time. It's added automatically in the API response.
    // or
    // 2. users enable in AddTokenViewController.
    // Default value is ["ETH", "WETH", "LRC"]
    private var tokenList: [String]
    
    // It will be removed manually.
    private var manuallyDisabledTokenList: [String]

    // totalCurrency is not persisted in disk
    var totalCurrency: Double = 0
    
    var nonce: Int64 = 0
    
    init(setupWalletMethod: QRCodeMethod, address: String, password: String, mnemonics: [String] = [], keystoreString: String, name: String, isVerified: Bool, totalCurrency: Double = 0, tokenList: [String], manuallyDisabledTokenList: [String]) {
        self.setupWalletMethod = setupWalletMethod
        self.address = address
        self.password = password
        self.mnemonics = mnemonics
        self.keystoreString = keystoreString
        self.name = name
        self.isVerified = isVerified

        self.tokenList = tokenList
        self.manuallyDisabledTokenList = manuallyDisabledTokenList

        super.init()
        
        if keystoreString == "" || !AppWallet.isKeystore(content: keystoreString) {
            print("Need to generate keystore")
            preconditionFailure("No keystore")
        }
    }

    func getTokenList() -> [String] {
        let mustHaveTokens = ["ETH", "WETH", "LRC"].reversed()
        for mustHaveToken in mustHaveTokens {
            if let indexOfA = tokenList.index(of: mustHaveToken) {
                tokenList.remove(at: indexOfA)
            }
            tokenList.insert(mustHaveToken, at: 0)
        }
        return tokenList
    }
    
    func updateTokenList(_ tokenSymbols: [String], add: Bool) {
        for tokenSymbol in tokenSymbols {
            if add {
                if !tokenList.contains(tokenSymbol) {
                    tokenList.append(tokenSymbol)
                }
            } else {
                
            }
        }
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: self)
    }
    
    func getManuallyDisabledTokenList() -> [String] {
        return manuallyDisabledTokenList
    }
    
    // Only used in AddTokenTableViewCell
    func updateTokenListManually(_ tokenSymbols: [String], add: Bool) {
        for tokenSymbol in tokenSymbols {
            if add {
                if !tokenList.contains(tokenSymbol) {
                    tokenList.append(tokenSymbol)
                }
                if manuallyDisabledTokenList.contains(tokenSymbol) {
                    manuallyDisabledTokenList = manuallyDisabledTokenList.filter {$0 != tokenSymbol}
                }
            } else {
                tokenList = tokenList.filter {$0 != tokenSymbol}
                if let balance = CurrentAppWalletDataManager.shared.getBalance(of: tokenSymbol) {
                    if balance > 0.01 {
                        manuallyDisabledTokenList.append(tokenSymbol)
                    }
                }
            }
        }
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: self)
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
    
    func getKeystore() -> String {
        return keystoreString
    }
    
    func getKeystorePassword() -> String {
        if setupWalletMethod == .importUsingPrivateKey || (setupWalletMethod == .importUsingMnemonic && password == "") {
            return keystorePassword
        } else {
            return password
        }
    }
    
    func getPassword() -> String {
        return password
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(setupWalletMethod.rawValue, forKey: "setupWalletMethod")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(isVerified, forKey: "isVerified")
        aCoder.encode(mnemonics, forKey: "mnemonics")
        aCoder.encode(keystoreString, forKey: "keystore")
        aCoder.encode(tokenList, forKey: "tokenList")
        aCoder.encode(manuallyDisabledTokenList, forKey: "manuallyDisabledTokenList")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let setupWalletMethodString = aDecoder.decodeObject(forKey: "setupWalletMethod") as? String ?? ""
        
        // If setupWalletMethod is null, the default value is importUsingPrivateKey
        let setupWalletMethod = QRCodeMethod(rawValue: setupWalletMethodString) ?? QRCodeMethod.importUsingPrivateKey
        
        let password = aDecoder.decodeObject(forKey: "password") as? String
        let address = aDecoder.decodeObject(forKey: "address") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let isVerified = aDecoder.containsValue(forKey: "isVerified") ? aDecoder.decodeBool(forKey: "isVerified") : false
        
        // TODO: mnemonics vs. mnemonic
        let mnemonics = aDecoder.decodeObject(forKey: "mnemonics") as? [String]
        
        let keystoreString = aDecoder.decodeObject(forKey: "keystore") as? String

        // Token list related
        let tokenList = aDecoder.decodeObject(forKey: "tokenList") as? [String] ?? []
        let filteredTokenList = tokenList.filter { (item) -> Bool in
            return item.trim() != ""
        }
        let manuallyDisabledTokenList = aDecoder.decodeObject(forKey: "manuallyDisabledTokenList") as? [String] ?? []
        let filteredManuallyDisabledTokenList = manuallyDisabledTokenList.filter { (item) -> Bool in
            return item.trim() != ""
        }

        if let address = address, let password = password, let mnemonics = mnemonics, let keystoreString = keystoreString, let name = name {
            // Verify keystore
            if keystoreString == "" || !AppWallet.isKeystore(content: keystoreString) {
                return nil
            }
            self.init(setupWalletMethod: setupWalletMethod, address: address, password: password, mnemonics: mnemonics, keystoreString: keystoreString, name: name, isVerified: isVerified, tokenList: unique(filteredTokenList), manuallyDisabledTokenList: unique(filteredManuallyDisabledTokenList))
        } else {
            return nil
        }
    }
    
    // TODO: this doesn't work in result.contains(value)
    static func == (lhs: AppWallet, rhs: AppWallet) -> Bool {
        return lhs.address.uppercased() == rhs.address.uppercased()
    }

}
