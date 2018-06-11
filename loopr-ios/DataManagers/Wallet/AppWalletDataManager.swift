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
    private var accountTotalCurrency: Double = 0
    
    private init() {
        appWallets = []
    }
    
    func setup() {
        getAppWalletsFromLocalStorage()
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
    
    func isWalletVerified(address: String) -> Bool {
        getAppWalletsFromLocalStorage()
        let appWallets = self.appWallets.filter { $0.address == address }
        if appWallets.count != 1 {
            return false
        }
        return appWallets[0].isVerified
    }

    func isNewWalletNameToken(newWalletname: String) -> Bool {
        let results = appWallets.filter { $0.name == newWalletname }
        return results.isEmpty
    }
    
    func isDuplicatedAddress(address: String) -> Bool {
        if address.trim() == "" {
            return true
        }
        let results = appWallets.filter { $0.address == address }
        return !results.isEmpty
    }

    func getWallets() -> [AppWallet] {
        return appWallets
    }

    func getAppWalletsFromLocalStorage() {
        let defaults = UserDefaults.standard
        if let decodedData = defaults.data(forKey: UserDefaultsKeys.appWallets.rawValue) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: decodedData)
            do {
                // The try is to prevent a crash when the product name is changed.
                _ = try unarchiver.decodeTopLevelObject()
                let appWallets = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [AppWallet]
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

    func addWallet(setupWalletMethod: QRCodeMethod, walletName: String, mnemonics: [String], password: String, derivationPath: String, key: Int, isVerified: Bool) throws -> AppWallet {
        guard key >= 0 else {
            throw AddWalletError.invalidInput
        }
        
        guard walletName.trim().count > 0 else {
            throw AddWalletError.invalidWalletName
        }
        
        let mnemonicString = mnemonics.joined(separator: " ")
        let wallet = Wallet(mnemonic: mnemonicString, password: password)
        
        // Public address
        let address = wallet.getKey(at: 0).address
        print(address.description)
        
        // Check if the address has been imported.
        if isDuplicatedAddress(address: address.description) {
            throw AddWalletError.duplicatedAddress
        }
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
        
        // TODO: Keystore
        
        let newAppWallet = AppWallet(setupWalletMethod: setupWalletMethod, address: address.description, privateKey: privateKey.hexString, password: password, mnemonics: mnemonics, name: walletName.trim(), isVerified: isVerified, active: true)
        
        // Update the new app wallet in the local storage.
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        // Set the current AppWallet.
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet)
        
        return newAppWallet
    }

}
