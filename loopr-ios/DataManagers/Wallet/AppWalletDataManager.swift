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
    private var accountTotalCurrency: Double = 0
    
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
    
    func logout(appWallet: AppWallet) {
        if let index = appWallets.index(of: appWallet) {
            appWallets.remove(at: index)
            // TODO: if the size of encodedData is large, the perfomance may drop.
            DispatchQueue.global().async {
                let defaults = UserDefaults.standard
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: AppWalletDataManager.shared.appWallets)
                defaults.set(encodedData, forKey: UserDefaultsKeys.appWallets.rawValue)
            }
            
            // Set the current wallet
            if appWallet == CurrentAppWalletDataManager.shared.getCurrentAppWallet() {
                if  appWallets.count > 0 {
                    let appWallet = AppWalletDataManager.shared.appWallets[0]
                    CurrentAppWalletDataManager.shared.setCurrentAppWallet(appWallet)
                } else {
                    return
                }
            }
        } else {
            return
        }
    }
    
    func getAccountTotalCurrency() -> Double {
        var result: Double = 0
        for wallet in appWallets {
            result += wallet.totalCurrency
        }
        return result
    }

    func getWallets() -> [AppWallet] {
        return appWallets
    }

    func getAppWalletsFromLocalStorage() {
        let defaults = UserDefaults.standard
        if let decodedData = defaults.data(forKey: UserDefaultsKeys.appWallets.rawValue) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: decodedData)
            do {
                let decodedDataObject = try unarchiver.decodeTopLevelObject()
                let appWallets = decodedDataObject as? [AppWallet]
                if let appWallets = appWallets {
                    self.appWallets = appWallets
                }
            } catch {
                self.appWallets = []
                
            }
        }
    }

    // TODO: this function has been called too many time. Optimize it in the future.
    func updateAppWalletsInLocalStorage(newAppWallet: AppWallet) {
        if let index = appWallets.index(of: newAppWallet) {
            appWallets[index] = newAppWallet
        } else {
            appWallets.insert(newAppWallet, at: 0)
        }

        // TODO: if the size of encodedData is large, the perfomance may drop.
        DispatchQueue.global().async {
            let defaults = UserDefaults.standard
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.appWallets)
            defaults.set(encodedData, forKey: UserDefaultsKeys.appWallets.rawValue)
        }
    }

    // TODO: Use error handling instead of returning a Bool value
    func addWallet(setupWalletMethod: SetupWalletMethod, walletName: String, mnemonics: [String], password: String, derivationPath: String, key: Int) -> AppWallet? {
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

        let newAppWallet = AppWallet(setupWalletMethod: setupWalletMethod, address: address.description, privateKey: privateKey.hexString, password: password, mnemonics: mnemonics, name: walletNameLocal, active: true)

        // Update the new app wallet in the local storage.
        updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        // Set the current AppWallet.
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)

        return newAppWallet
    }

}
