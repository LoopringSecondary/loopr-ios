//
//  ImportWalletUsingPrivateKeyDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import secp256k1_ios

class ImportWalletUsingPrivateKeyDataManager: ImportWalletProtocol {
    
    static let shared = ImportWalletUsingPrivateKeyDataManager()
    
    var walletName: String
    
    // Password is no need
    final let password: String = ""
    
    var address: String
    private var privateKey: String
    private var keystore: String
    
    private init() {
        walletName = ""
        address = ""
        privateKey = ""
        keystore = ""
    }
    
    func reset() {
        walletName = ""
        address = ""
        privateKey = ""
        keystore = ""
    }
    
    func setKeystore(keystore: String) {
        self.keystore = keystore
    }
    
    func getPrivateKey() -> String {
        return privateKey
    }
    
    func importWallet(privateKey privateKeyString: String) throws {
        print("Start to unlock a new wallet using the private key")
        let privateKeyData: Data? = Data(hexString: privateKeyString.trim())
        guard privateKeyData != nil else {
            print("Invalid private key")
            throw ImportWalletError.invalidPrivateKey
        }
        
        // Store private key
        privateKey = privateKeyString.trim()
        
        // TODO: move this part to sdk?
        let pubKey = Secp256k1.shared.pubicKey(from: privateKeyData!)
        let keystoreAddress = KeystoreKey.decodeAddress(from: pubKey)
        
        // Store public key
        address = keystoreAddress.eip55String
    }
    
    func complete() throws {
        if AppWalletDataManager.shared.isDuplicatedAddress(address: address) {
            throw AddWalletError.duplicatedAddress
        }
        
        let newAppWallet = AppWallet(setupWalletMethod: .importUsingPrivateKey, address: address, password: password, keystoreString: keystore, name: walletName.trim(), isVerified: true, tokenList: ["ETH", "WETH", "LRC"], manuallyDisabledTokenList: [])
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet, completionHandler: {})
        
        // Inform relay
        LoopringAPIRequest.unlockWallet(owner: address) { (_, _) in }
        print("Finished unlocking a new wallet in ImportWalletUsingPrivateKeyDataManager")
    }
}
