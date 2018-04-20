//
//  ImportWalletUsingKeystoreDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import secp256k1_ios

class ImportWalletUsingKeystoreDataManager {
    
    static let shared = ImportWalletUsingKeystoreDataManager()
    
    private init() {
        
    }
    
    // TODO: Use error handling
    func unlockWallet(keystoreStringValue: String, password: String) {
        print("Start to unlock a new wallet using the keystore")
        print(keystoreStringValue)

        // Create two folders
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreImportWalletUsingKeystoreDataManager")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory)

        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletImportWalletUsingKeystoreDataManager")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory)

        // Save the keystore string value to keyDirectory
        let fileURL = keyDirectory.appendingPathComponent("key.json")
        try! keystoreStringValue.write(to: fileURL, atomically: false, encoding: .utf8)

        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        
        print(keyStore.accounts.count)
        let account = keyStore.accounts[0]
        print(account.address.description)
        
        let privateKeyData = try! keyStore.exportPrivateKey(account: account, password: "12345678")
        
        let privateKeyString = privateKeyData.toHexString()
        
        let pubKey = Secp256k1.shared.pubicKey(from: privateKeyData)
        let address = KeystoreKey.decodeAddress(from: pubKey)
        
        let newAppWallet = AppWallet(address: address.description, privateKey: privateKeyString, password: "12345678", name: "Wallet Keystore", active: true)
        
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
    }
}
