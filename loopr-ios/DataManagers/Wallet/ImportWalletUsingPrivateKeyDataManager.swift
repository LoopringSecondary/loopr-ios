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
    var privateKey: String

    private init() {
        walletName = ""
        address = ""
        privateKey = ""
    }

    func reset() {
        walletName = ""
        address = ""
        privateKey = ""
    }

    func unlockWallet(privateKey privateKeyString: String) throws {
        print("Start to unlock a new wallet using the private key")
        let privateKeyData: Data? = Data(hexString: privateKeyString.trim())
        guard privateKeyData != nil else {
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
    
    func complete() {
        let newAppWallet = AppWallet(address: address, privateKey: privateKey, password: password, name: walletName, active: true)
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet in ImportWalletUsingPrivateKeyDataManager")
    }

}
