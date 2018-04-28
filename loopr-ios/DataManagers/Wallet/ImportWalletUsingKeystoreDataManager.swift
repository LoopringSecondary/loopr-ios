//
//  ImportWalletUsingKeystoreDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import secp256k1_ios

class ImportWalletUsingKeystoreDataManager: ImportWalletProtocol {

    static let shared = ImportWalletUsingKeystoreDataManager()

    // Required fields
    var password: String
    
    var address: String
    var privateKey: String
    
    var walletName: String

    private init() {
        password = ""
        address = ""
        privateKey = ""
        walletName = ""
    }
    
    func reset() {
        password = ""
        address = ""
        privateKey = ""
        walletName = ""
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
        
        let privateKeyData = try! keyStore.exportPrivateKey(account: account, password: password)
        
        let privateKeyString = privateKeyData.toHexString()
        
        let pubKey = Secp256k1.shared.pubicKey(from: privateKeyData)
        let keystoreAddress = KeystoreKey.decodeAddress(from: pubKey)
        
        // Store values
        self.address = keystoreAddress.eip55String
        self.privateKey = privateKeyString
        self.password = password
    }
    
    func complete() {
        let newAppWallet = AppWallet(setupWalletMethod: .importUsingKeystore, address: address, privateKey: privateKey, password: password, name: walletName, active: true)
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet in ImportWalletUsingKeystoreDataManager")
    }

}
