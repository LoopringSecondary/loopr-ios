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
    
    func getCurrentAppWalletFromLocalStorage() {
        let defaults = UserDefaults.standard
        if let privateKeyString = defaults.string(forKey: UserDefaultsKeys.currentAppWallet.rawValue) {
            let privateKey = Data(hexString: privateKeyString)!
            let key = try! KeystoreKey(password: "password", key: privateKey)
            let newAppWallet = AppWallet(address: key.address.description, privateKey: privateKeyString, name: "Wallet private key", active: true)
            appWallets.append(newAppWallet)
            setCurrentAppWallet(newAppWallet)
        }
    }
    
    func getCurrentAppWallet() -> AppWallet? {
        return currentAppWallet
    }
    
    func setCurrentAppWallet(_ appWallet: AppWallet) {
        let defaults = UserDefaults.standard
        defaults.set(appWallet.privateKey, forKey: UserDefaultsKeys.currentAppWallet.rawValue)
        currentAppWallet = appWallet
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
    
    func AddAndUpdateAppWalletsInLocalStorage(newAppWallet: AppWallet) {
        appWallets.append(newAppWallet)
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
        
        AddAndUpdateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
    }
    
    // TODO: Use error handling
    func unlockWallet(mnemonic: String) {
        let wallet = Wallet(mnemonic: mnemonic, password: "")
        let address = wallet.getKey(at: 0).address
        let newAppWallet = AppWallet(address: address.description, privateKey: "", name: "Wallet mnemonic", active: true)
        
        AddAndUpdateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        setCurrentAppWallet(newAppWallet)
        print("Finished unlocking a new wallet")
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

        let newAppWallet = AppWallet(address: address.description, privateKey: privateKey.hexString, name: walletNameLocal, active: true)
        
        AddAndUpdateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
        
        setCurrentAppWallet(newAppWallet)

        return newAppWallet
    }

}
