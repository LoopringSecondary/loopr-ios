//
//  WalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class WalletDataManager {
    
    static let shared = WalletDataManager()
    
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
    
    func unlockWalletUsingPrivateKey(_ privateKeyString: String) {
        print("Start to unlock a new wallet using the private key")
        let privateKey = Data(hexString: privateKeyString)!
        let key = try! KeystoreKey(password: "password", key: privateKey)
        let newAppWallet = AppWallet(address: key.address.description, name: "Wallet", active: true)
        appWallets.append(newAppWallet)
        setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }

    func generateWalletAndReturnMnemonic() -> [String] {
        let mnemonicString = Mnemonic.generate(strength: 256)
        let mnemonic = mnemonicString.components(separatedBy: " ")
        return mnemonic
    }

    func generateMockData() {
        let wallet1 = AppWallet(address: "#1234567890qwertyuiop1", name: "Wallet 1", active: true)
        let wallet2 = AppWallet(address: "#1234567890qwertyuiop2", name: "Wallet 2", active: true)
        let wallet3 = AppWallet(address: "#1234567890qwertyuiop3", name: "Wallet 3", active: true)

        appWallets = [wallet1, wallet2, wallet3]
        setCurrentAppWallet(wallet1)
    }
}
