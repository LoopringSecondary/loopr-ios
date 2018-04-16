//
//  ImportWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class ImportWalletUsingMnemonicDataManager {
    
    static let shared = ImportWalletUsingMnemonicDataManager()

    var mnemonic: String = ""
    var password: String = ""
    var derivationPathValue = "m/44'/60'/0'/0"
    var selectedKey: Int = 0
    var addresses: [Address] = []
    
    var walletName: String = ""
    
    private init() {
        
    }

    func isMnemonicValid(mnemonic: String) -> Bool {
        return Mnemonic.isValid(mnemonic)
    }

    // TODO: Use error handling
    func unlockWallet(privateKey privateKeyString: String) {
        print("Start to unlock a new wallet using the private key")
        let privateKey = Data(hexString: privateKeyString)!
        let key = try! KeystoreKey(password: "password", key: privateKey)
        let newAppWallet = AppWallet(address: key.address.description, privateKey: privateKeyString, name: "Wallet private key", active: true)

        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)

        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }

    // TODO: Use error handling
    func unlockWallet(mnemonic: String) {
        let wallet = Wallet(mnemonic: mnemonic, password: "")
        let address = wallet.getKey(at: 0).address
        let newAppWallet = AppWallet(address: address.description, privateKey: "", name: "Wallet mnemonic", active: true)

        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }

    func clearAddresses() {
        selectedKey = 0
        addresses = []
    }

    func generateAddresses() {
        // append "/x"
        let pathValue = derivationPathValue + "/x"

        for i in 0..<30 {
            let key = (addresses.count) + i
            let wallet = Wallet(mnemonic: mnemonic, password: password, path: pathValue)
            let address = wallet.getKey(at: key).address
            addresses.append(address)
        }
    }
    
    func complete() {
        let pathValue = derivationPathValue + "/x"
        let appWallet = AppWalletDataManager.shared.addWallet(walletName: walletName, mnemonics: mnemonic.components(separatedBy: " "), password: password, derivationPath: pathValue, key: selectedKey)
    }
}
