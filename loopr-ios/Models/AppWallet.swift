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
    final let privateKey: String
    
    // The password used to get the address and the private key
    // when users use mnemonics and keystore.
    // At the same time, generating a keystore requires password.
    // However, importing a wallet using private key doesn't require password.
    // Use a default password
    // At this usecase, users won't export keystore
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
    
    var totalCurrency: Double = 0
    var assetSequence: [String] = []
    var assetSequenceInHideSmallAssets: [String] = []
    
    init(setupWalletMethod: QRCodeMethod, address: String, privateKey: String, password: String, mnemonics: [String] = [], keystoreString: String, name: String, isVerified: Bool, active: Bool, totalCurrency: Double = 0, assetSequence: [String] = [], assetSequenceInHideSmallAssets: [String] = []) {
        self.setupWalletMethod = setupWalletMethod
        self.address = address
        self.privateKey = privateKey
        self.password = password
        self.mnemonics = mnemonics
        self.keystoreString = keystoreString
        self.name = name
        self.isVerified = isVerified
        self.assetSequence = assetSequence
        self.assetSequenceInHideSmallAssets = assetSequenceInHideSmallAssets
        
        super.init()
        
        print("########################## keystoreString ##########################")
        print(keystoreString)
        print("########################## end ##########################")
        if keystoreString == "" || !AppWallet.isKeystore(content: keystoreString) {
            print("Need to generate keystore")
            preconditionFailure("No keystore")
            // generateKeystoreInBackground()
        }
    }
    
    func getAssetSequence() -> [String] {
        return assetSequence
    }
    
    func addAssetSequence(symbol: String) {
        if symbol.trim() != "" && !assetSequence.contains(symbol) {
            assetSequence.append(symbol)
        }
    }
    
    func getAssetSequenceInHideSmallAssets() -> [String] {
        return assetSequenceInHideSmallAssets
    }
    
    func addAssetSequenceInHideSmallAssets(symbol: String) {
        if symbol.trim() != "" && !assetSequenceInHideSmallAssets.contains(symbol) {
            assetSequenceInHideSmallAssets.append(symbol)
        }
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
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(isVerified, forKey: "isVerified")
        aCoder.encode(mnemonics, forKey: "mnemonics")
        aCoder.encode(keystoreString, forKey: "keystore")
        aCoder.encode(assetSequence, forKey: "assetSequence")
        aCoder.encode(assetSequenceInHideSmallAssets, forKey: "assetSequenceInHideSmallAssets")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let setupWalletMethodString = aDecoder.decodeObject(forKey: "setupWalletMethod") as? String ?? ""
        
        // If setupWalletMethod is null, the default value is importUsingPrivateKey
        let setupWalletMethod = QRCodeMethod(rawValue: setupWalletMethodString) ?? QRCodeMethod.importUsingPrivateKey
        
        let password = aDecoder.decodeObject(forKey: "password") as? String
        let address = aDecoder.decodeObject(forKey: "address") as? String
        let privateKey = aDecoder.decodeObject(forKey: "privateKey") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let isVerified = aDecoder.containsValue(forKey: "isVerified") ? aDecoder.decodeBool(forKey: "isVerified") : false
        let active = aDecoder.decodeBool(forKey: "active")
        
        // TODO: mnemonics vs. mnemonic
        let mnemonics = aDecoder.decodeObject(forKey: "mnemonics") as? [String]
        
        let keystoreString = aDecoder.decodeObject(forKey: "keystore") as? String
        
        let assetSequence = aDecoder.decodeObject(forKey: "assetSequence") as? [String] ?? []
        let filteredAssetSequence = assetSequence.filter { (item) -> Bool in
            return item.trim() != ""
        }
        
        let assetSequenceInHideSmallAssets = aDecoder.decodeObject(forKey: "assetSequenceInHideSmallAssets") as? [String] ?? []
        let filteredAssetSequenceInHideSmallAssets = assetSequenceInHideSmallAssets.filter { (item) -> Bool in
            return item.trim() != ""
        }
        
        if let address = address, let privateKey = privateKey, let password = password, let mnemonics = mnemonics, let keystoreString = keystoreString, let name = name {
            // Verify keystore
            if keystoreString == "" || !AppWallet.isKeystore(content: keystoreString) {
                return nil
            }
            self.init(setupWalletMethod: setupWalletMethod, address: address, privateKey: privateKey, password: password, mnemonics: mnemonics, keystoreString: keystoreString, name: name, isVerified: isVerified, active: active, assetSequence: unique(filteredAssetSequence), assetSequenceInHideSmallAssets: unique(filteredAssetSequenceInHideSmallAssets))
        } else {
            return nil
        }
    }
    
    // TODO: this doesn't work in result.contains(value)
    static func == (lhs: AppWallet, rhs: AppWallet) -> Bool {
        return lhs.address.uppercased() == rhs.address.uppercased() && lhs.privateKey.uppercased() == rhs.privateKey.uppercased()
    }

}
