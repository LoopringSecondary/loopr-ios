//
//  WalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SVProgressHUD

class AppWalletDataManager {
    
    static let shared = AppWalletDataManager()
    private var appWallets: [AppWallet]
    
    private init() {
        appWallets = []
    }
    
    func setup() {
        getAppWalletsFromLocalStorage()
        // Move this part to WalletViewController to speed up the app launch time.
        // getAllBalanceFromRelay()
    }
    
    func logout(appWalletToBeDeleted: AppWallet) {
        print("before logout: \(appWallets.count)")
        if let index = appWallets.index(of: appWalletToBeDeleted) {
            appWallets.remove(at: index)
            let defaults = UserDefaults.standard
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: AppWalletDataManager.shared.appWallets)
            defaults.set(encodedData, forKey: UserDefaultsKeys.appWallets.rawValue)
            getAppWalletsFromLocalStorage()
            
            // Remove the address from the app service
            PushNotificationDeviceDataManager.shared.remove(address: appWalletToBeDeleted.address)
            
            print("after logout: \(appWallets.count)")

            // Set the current wallet
            if let currentAppWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet() {
                if appWalletToBeDeleted == currentAppWallet {
                    if  appWallets.count > 0 {
                        CurrentAppWalletDataManager.shared.setCurrentAppWallet(AppWalletDataManager.shared.appWallets[0], completionHandler: {})
                    }
                }
            } else {
                if  appWallets.count > 0 {
                    CurrentAppWalletDataManager.shared.setCurrentAppWallet(AppWalletDataManager.shared.appWallets[0], completionHandler: {})
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
        let appWallets = self.appWallets.filter { $0.address.uppercased() == address.uppercased() }
        if appWallets.count != 1 {
            return false
        }
        return appWallets[0].isVerified
    }
    
    func isNewWalletNameToken(newWalletname: String) -> Bool {
        getAppWalletsFromLocalStorage()
        let results = appWallets.filter { $0.name == newWalletname }
        return !results.isEmpty
    }
    
    func isDuplicatedAddress(address: String) -> Bool {
        getAppWalletsFromLocalStorage()
        if address.trim() == "" {
            return true
        }
        let results = appWallets.filter { $0.address.uppercased() == address.uppercased() }
        return !results.isEmpty
    }
    
    func getWallet(address: String) -> AppWallet? {
        let results = appWallets.filter { $0.address.uppercased() == address.uppercased() }
        if !results.isEmpty {
            return results[0]
        } else {
            return nil
        }
    }
    
    func getWallets() -> [AppWallet] {
        // Remove duplicate items
        var results: [AppWallet] = []
        for appWallet in self.appWallets {
            var found = false
            for result in results where appWallet == result {
                found = true
            }
            if !found {
                results.append(appWallet)
            }
        }
        return results
    }

    func getAppWalletsFromLocalStorage() {
        let defaults = UserDefaults.standard
        if let decodedData = defaults.data(forKey: UserDefaultsKeys.appWallets.rawValue) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: decodedData)
            do {
                // The try is to prevent a crash when the product name is changed.
                _ = try unarchiver.decodeTopLevelObject()
                let appWalletsFromKeyedUnarchiver = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [AppWallet]
                if let appWalletsFromKeyedUnarchiver = appWalletsFromKeyedUnarchiver {
                    self.appWallets = appWalletsFromKeyedUnarchiver
                }
                
                // Remove duplicate items
                var results: [AppWallet] = []
                for appWallet in self.appWallets {
                    var found = false
                    for result in results where appWallet == result {
                        found = true
                    }
                    if !found {
                        results.append(appWallet)
                    }
                }
                self.appWallets = results

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
        
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.appWallets)
        defaults.set(encodedData, forKey: UserDefaultsKeys.appWallets.rawValue)
    }
    
    // Used in GenerateWallet and ImportMnemonic
    func addWallet(setupWalletMethod: QRCodeMethod, walletName: String, mnemonics: [String], password: String, devicePassword: String, derivationPath: String, key: Int, isVerified: Bool, completionHandler: @escaping (_ appWallet: AppWallet?, _ error: AddWalletError?) -> Void) {
        guard key >= 0 else {
            completionHandler(nil, AddWalletError.invalidInput)
            return
        }
        
        guard walletName.trim().count > 0 else {
            completionHandler(nil, AddWalletError.invalidInput)
            return
        }
        
        let mnemonicString = mnemonics.joined(separator: " ")
        let wallet = Wallet(mnemonic: mnemonicString, password: password, path: derivationPath)
        
        // Public address
        let address = wallet.getKey(at: key).address
        print(address.description)
        
        // Check if the address has been imported.
        if isDuplicatedAddress(address: address.description) {
            completionHandler(nil, AddWalletError.duplicatedAddress)
            return
        }
        
        // Private key
        let privateKey = wallet.getKey(at: key).privateKey
        
        // Generate keystore
        var keystoreString: String
        guard let data = Data(hexString: privateKey.hexString) else {
            print("Invalid private key")
            completionHandler(nil, AddWalletError.invalidInput)
            return
        }
        do {
            print("Generating keystore")
            let start = Date()
            
            var localPassword = password
            if password == "" {
                localPassword = devicePassword
            }

            let key = try KeystoreKey(password: localPassword, key: data)
            
            let end = Date()
            let timeInterval: Double = end.timeIntervalSince(start)
            print("##########Time to generate keystore: \(timeInterval) seconds############")
            print("Finished generating keystore")
            
            let keystoreData = try JSONEncoder().encode(key)
            let json = try JSON(data: keystoreData)
            
            keystoreString = json.description
            guard keystoreString != "" else {
                print("Failed to generate keystore")
                completionHandler(nil, AddWalletError.invalidKeystore)
                return
            }
        } catch {
            completionHandler(nil, AddWalletError.invalidKeystore)
            return
        }
        
        var newAppWallet: AppWallet?
        if setupWalletMethod == .create {
            newAppWallet = AppWallet(setupWalletMethod: setupWalletMethod, address: address.description, password: password, devicePassword: "", mnemonics: mnemonics, keystoreString: keystoreString, name: walletName.trim(), isVerified: isVerified, tokenList: ["ETH", "WETH", "LRC"], manuallyDisabledTokenList: [])
        } else if setupWalletMethod == .importUsingMnemonic {
            newAppWallet = AppWallet(setupWalletMethod: setupWalletMethod, address: address.description, password: password, devicePassword: devicePassword, mnemonics: mnemonics, keystoreString: keystoreString, name: walletName.trim(), isVerified: isVerified, tokenList: ["ETH", "WETH", "LRC"], manuallyDisabledTokenList: [])
        } else {
            preconditionFailure("unsupported setupWalletMethod in addWallet method in AppWalletDataManager")
        }
        
        guard newAppWallet != nil else {
            completionHandler(nil, AddWalletError.invalidInput)
            return
        }
        
        // Update the new app wallet in the local storage.
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet!)
        
        // Set the current AppWallet.
        CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet!, completionHandler: {})
        
        completionHandler(newAppWallet, nil)
    }
    
    func getTotalCurrencyValue(address: String, getPrice: Bool, completionHandlerInBackgroundThread: @escaping (_ totalCurrencyValue: Double, _ error: Error?) -> Void) {
        print("getTotalCurrencyValue Current address: \(address)")
        
        let appWallet = getWallet(address: address)
        var localAssets: [Asset] = []
        let dispatchGroup = DispatchGroup()
        
        if getPrice {
            dispatchGroup.enter()
            let currency = SettingDataManager.shared.getCurrentCurrency().name
            LoopringAPIRequest.getPriceQuote(currency: currency, completionHandler: { (priceQuote, error) in
                print("receive LoopringAPIRequest.getPriceQuote ....")
                guard error == nil else {
                    print("error=\(String(describing: error))")
                    dispatchGroup.leave()
                    return
                }
                PriceDataManager.shared.setPriceQuote(newPriceQuote: priceQuote!)
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.enter()
        LoopringAPIRequest.getBalance(owner: address) { assets, error in
            print("receive LoopringAPIRequest.getBalance ...")
            guard error == nil else {
                print("error=\(String(describing: error))")
                dispatchGroup.leave()
                return
            }
            localAssets = assets
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global(qos: .background)) {
            print("Both functions complete 👍")
            
            var newTokenList: [String] = []
            var totalCurrencyValue: Double = 0
            for asset in localAssets {
                // If the price quote is nil, asset won't be updated. Please use getBalanceAndPriceQuote()
                if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
                    let total = asset.balance * price
                    asset.total = total
                    asset.currency = total.currency
                    totalCurrencyValue += total
                }
                
                if asset.balance > 0.1 || asset.total > 0.1 {
                    newTokenList.append(asset.symbol)
                }
            }
            
            if appWallet != nil {
                appWallet!.updateTokenList(newTokenList, add: true)
            }

            completionHandlerInBackgroundThread(totalCurrencyValue, nil)
        }
    }
    
    // Not used in WalletViewController. 
    func getAllBalanceFromRelayInBackgroundThread() {
        for wallet in AppWalletDataManager.shared.getWallets() {
            // Closure is in the background thread.
            AppWalletDataManager.shared.getTotalCurrencyValue(address: wallet.address, getPrice: false, completionHandlerInBackgroundThread: { (totalCurrencyValue, error) in
                print("AppWalletDataManager getAllBalanceFromRelay \(totalCurrencyValue)")
                wallet.totalCurrency = totalCurrencyValue
                AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: wallet)
            })
        }
    }
}
