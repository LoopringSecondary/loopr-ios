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

    private var confirmedToLogout: Bool = false
    
    private init() {
        appWallets = []
    }
    
    func setup() {
        getAppWalletsFromLocalStorage()
    }

    // MARK: Logout
    func setConfirmedToLogout() {
        confirmedToLogout = true
    }
    
    func logout() -> Bool {
        if confirmedToLogout {
            appWallets = []
            let defaults = UserDefaults.standard
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: appWallets)
            defaults.set(encodedData, forKey: UserDefaultsKeys.appWallets.rawValue)
            confirmedToLogout = false
            return true
        }
        return false
    }

    func getWallets() -> [AppWallet] {
        return appWallets
    }

    func getAppWalletsFromLocalStorage() {
        let defaults = UserDefaults.standard
        if let decoded = defaults.data(forKey: UserDefaultsKeys.appWallets.rawValue) {
            let appWallets = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [AppWallet]
            if let appWallets = appWallets {
                self.appWallets = appWallets
            }
        }
    }

    func updateAppWalletsInLocalStorage(newAppWallet: AppWallet) {
        if let index = appWallets.index(of: newAppWallet) {
            appWallets[index] = newAppWallet
        } else {
            appWallets.insert(newAppWallet, at: 0)
        }

        // TODO: if the size of encodedData is large, the perfomance may drop.
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: appWallets)
        defaults.set(encodedData, forKey: UserDefaultsKeys.appWallets.rawValue)
    }

    // TODO: Use error handling
    func unlockWallet(privateKey privateKeyString: String) {
        print("Start to unlock a new wallet using the private key")
        let privateKey = Data(hexString: privateKeyString)!
        let key = try! KeystoreKey(password: "password", key: privateKey)
        let newAppWallet = AppWallet(address: key.address.description, privateKey: privateKeyString, name: "Wallet private key", active: true)
        
        updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)

        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }
    
    // TODO: Use error handling
    func unlockWallet(mnemonic: String) {
        let wallet = Wallet(mnemonic: mnemonic, password: "")
        let address = wallet.getKey(at: 0).address
        let newAppWallet = AppWallet(address: address.description, privateKey: "", name: "Wallet mnemonic", active: true)
        
        updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }

    // TODO: Use error handling instead of returning a Bool value
    func addWallet(walletName: String, mnemonics: [String]) -> AppWallet? {
        guard mnemonics.count == 24 else {
            return nil
        }
        
        let mnemonicString = mnemonics.joined(separator: " ")
        let wallet = Wallet(mnemonic: mnemonicString, password: "")

        // Public address
        let address = wallet.getKey(at: 0).address
        print(address.description)
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
        
        // TODO: Keystore

        var walletNameLocal: String
        if walletName.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0 {
            walletNameLocal = "Wallet \(appWallets.count+1)"
        } else {
            walletNameLocal = walletName
        }

        let newAppWallet = AppWallet(address: address.description, privateKey: privateKey.hexString, name: walletNameLocal, active: true, mnemonics: mnemonics)
        
        // Update the new app wallet in the local storage.
        updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)

        return newAppWallet
    }

}
