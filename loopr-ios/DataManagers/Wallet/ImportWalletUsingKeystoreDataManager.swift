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
    var keystore: String
    var walletName: String

    private init() {
        password = ""
        address = ""
        privateKey = ""
        keystore = ""
        walletName = ""
    }
    
    func reset() {
        password = ""
        address = ""
        privateKey = ""
        keystore = ""
        walletName = ""
    }

    func unlockWallet(userInputKeystoreStringValue: String, password: String) throws {
        print("Start to unlock a new wallet using the keystore")
        do {
            let decoder = JSONDecoder()
            let newkeystoreData: Data = userInputKeystoreStringValue.data(using: .utf8)! 
            let newkeystore = try decoder.decode(NewKeystore.self, from: newkeystoreData)
            
            let privateKey = try newkeystore.privateKey(password: password)
            guard let data = Data(hexString: privateKey.toHexString()) else {
                print("Invalid private key")
                throw ImportWalletError.invalidKeystore
            }
            
            print("Re-Generating keystore")
            let key = try KeystoreKey(password: password, key: data)
            print("Finished generating keystore")
            let keystoreData = try JSONEncoder().encode(key)
            let json = try JSON(data: keystoreData)
            let keystoreStringValue = json.description

            // Store values
            self.address = key.address.eip55String
            self.privateKey = privateKey.toHexString()
            self.keystore = keystoreStringValue
            self.password = password
            
            print("Complete unlockWallet using keystore")
        } catch {
            print("Invalid keystore")
            throw ImportWalletError.invalidKeystore
        }
    }
    
    func complete() throws {
        if AppWalletDataManager.shared.isDuplicatedAddress(address: address) {
            throw AddWalletError.duplicatedAddress
        }

        let newAppWallet = AppWallet(setupWalletMethod: .importUsingKeystore, address: address, privateKey: privateKey, password: password, keystoreString: keystore, name: walletName.trim(), isVerified: true, tokenList: ["ETH", "WETH", "LRC"])
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        // Inform relay
        LoopringAPIRequest.unlockWallet(owner: address) { (_, _) in }
        print("Finished unlocking a new wallet in ImportWalletUsingKeystoreDataManager")
    }

}
