//
//  ImportWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class ImportWalletUsingMnemonicDataManager: ImportWalletProtocol {
    
    static let shared = ImportWalletUsingMnemonicDataManager()

    var mnemonic: String = ""
    var password: String = ""
    var derivationPathValue = "m/44'/60'/0'/0"
    var selectedKey: Int = 0
    var addresses: [Address] = []
    
    var walletName: String = ""
    
    private init() {
        
    }
    
    func reset() {
        
    }

    func isMnemonicValid(mnemonic: String) -> Bool {
        return Mnemonic.isValid(mnemonic)
    }

    /*
    // TODO: Use error handling
    func unlockWallet(mnemonic: String) {
        let wallet = Wallet(mnemonic: mnemonic, password: "")
        let address = wallet.getKey(at: 0).address
        let newAppWallet = AppWallet(setupWalletMethod: .importUsingMnemonic, address: address.description, privateKey: "", password: password, mnemonics: mnemonic.components(separatedBy: " "), name: "Wallet mnemonic", active: true)

        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }
    */

    func clearAddresses() {
        selectedKey = 0
        addresses = []
    }

    func generateAddresses() {
        // append "/x"
        let pathValue = derivationPathValue + "/x"

        // TODO: in theory, it should generate many many addresses. However, we should only top 100 addresses. Improve in the future.
        for i in 0..<100 {
            let key = (addresses.count) + i
            let wallet = Wallet(mnemonic: mnemonic, password: password, path: pathValue)
            let address = wallet.getKey(at: key).address
            addresses.append(address)
        }
    }
    
    func complete() {
        let pathValue = derivationPathValue + "/x"
        let wallet = AppWalletDataManager.shared.addWallet(setupWalletMethod: .importUsingMnemonic, walletName: walletName, mnemonics: mnemonic.components(separatedBy: " "), password: password, derivationPath: pathValue, key: selectedKey)
        // Inform relay
        LoopringAPIRequest.unlockWallet(owner: wallet!.address) { (_, _) in }
    }
}
