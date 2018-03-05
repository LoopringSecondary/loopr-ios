//
//  WalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class AppWalletDataManager {
    
    static let shared = AppWalletDataManager()
    
    private var appWallets: [AppWallet]
    
    private init() {
        appWallets = []
    }

    private var currentAppWallet: AppWallet?
    
    func getCurrentAppWallet() -> AppWallet? {
        return currentAppWallet
    }
    
    func setCurrentAppWallet(_ appWallet: AppWallet) {
        currentAppWallet = appWallet
    }
    
    func getWallets() -> [AppWallet] {
        return appWallets
    }
    
    // TODO: Use error handling
    func unlockWallet(privateKey privateKeyString: String) {
        print("Start to unlock a new wallet using the private key")
        let privateKey = Data(hexString: privateKeyString)!
        let key = try! KeystoreKey(password: "password", key: privateKey)
        let newAppWallet = AppWallet(address: key.address.description, name: "Wallet private key", active: true)
        appWallets.append(newAppWallet)
        setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }
    
    // TODO: Use error handling
    func unlockWallet(mnemonic: String) {
        let wallet = Wallet(mnemonic: mnemonic, password: "")
        let address = wallet.getKey(at: 0).address
        let newAppWallet = AppWallet(address: address.description, name: "Wallet mnemonic", active: true)
        appWallets.append(newAppWallet)
        setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }

    func generateMockData() {
        let wallet1 = AppWallet(address: "#1234567890qwertyuiop1", name: "Wallet 1", active: true)
        let wallet2 = AppWallet(address: "#1234567890qwertyuiop2", name: "Wallet 2", active: true)
        let wallet3 = AppWallet(address: "#1234567890qwertyuiop3", name: "Wallet 3", active: true)

        appWallets = [wallet1, wallet2, wallet3]
        setCurrentAppWallet(wallet1)
    }
    
    // TODO: Use error handling instead of returning a Bool value
    func addWallet(walletName: String?, mnemonic: [String]) -> AppWallet? {
        guard mnemonic.count == 24 else {
            return nil
        }
        
        let mnemonicString = mnemonic.joined(separator: " ")
        let wallet = Wallet(mnemonic: mnemonicString, password: "")

        // Public address
        let address = wallet.getKey(at: 0).address
        print(address.description)
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
        
        var walletNameLocal: String
        if walletName == nil {
            walletNameLocal = "Wallet \(appWallets.count+1)"
        } else {
            walletNameLocal = walletName!
        }

        let newAppWallet = AppWallet(address: address.description, name: walletNameLocal, active: true)
        appWallets.append(newAppWallet)
        setCurrentAppWallet(newAppWallet)

        return newAppWallet
    }

}
