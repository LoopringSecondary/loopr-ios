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

    // TODO: Use error handling instead of returning a Bool value
    func addWallet(walletName: String, mnemonics: [String], password: String, derivationPath: String, key: Int) -> AppWallet? {
        guard key >= 0 else {
            return nil
        }

        let mnemonicString = mnemonics.joined(separator: " ")
        let wallet = Wallet(mnemonic: mnemonicString, password: password)

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

        let newAppWallet = AppWallet(address: address.description, privateKey: privateKey.hexString, password: password, mnemonics: mnemonics, name: walletNameLocal, active: true)

        // Update the new app wallet in the local storage.
        updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        // Set the current AppWallet.
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)

        return newAppWallet
    }

}
