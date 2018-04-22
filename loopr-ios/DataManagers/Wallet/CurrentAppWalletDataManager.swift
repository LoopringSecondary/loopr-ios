//
//  CurrentAppWalletDataManager.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import BigInt

class CurrentAppWalletDataManager {

    static let shared = CurrentAppWalletDataManager()
    
    private var currentAppWallet: AppWallet?
    
    private var totalCurrencyValue: Double

    private var assetsInHideSmallMode: [Asset]
    private var assets: [Asset]
    
    private var transactions: [Transaction]
    
    private init() {
        self.assetsInHideSmallMode = []
        self.assets = []
        self.transactions = []
        self.totalCurrencyValue = 0
    }
    
    func setup() {
        getCurrentAppWalletFromLocalStorage()
    }
    
    func getCurrentAppWalletFromLocalStorage() {
        let defaults = UserDefaults.standard
        if let privateKeyString = defaults.string(forKey: UserDefaultsKeys.currentAppWallet.rawValue) {
            for appWallet in AppWalletDataManager.shared.getWallets() where appWallet.privateKey == privateKeyString {
                setCurrentAppWallet(appWallet)
            }
        }
    }
    
    func getCurrentAppWallet() -> AppWallet? {
        return currentAppWallet
    }

    func setCurrentAppWallet(_ appWallet: AppWallet) {
        print("setCurrentAppWallet ...")
        let defaults = UserDefaults.standard
        defaults.set(appWallet.privateKey, forKey: UserDefaultsKeys.currentAppWallet.rawValue)
        currentAppWallet = appWallet
        
        // Init assets using assetSequence in AppWallet
        for symbol in currentAppWallet!.assetSequence {
            let asset = Asset(symbol: symbol)
            assets.append(asset)
        }
        startGetBalance()
    }

    func getTotalAsset() -> Double {
        return totalCurrencyValue
    }
    
    func getTotalAssetCurrencyFormmat() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = NSLocale.current
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        let formattedNumber = currencyFormatter.string(from: NSNumber(value: totalCurrencyValue)) ?? "\(totalCurrencyValue)"
        return formattedNumber
    }

    func getAssets(enable: Bool? = nil) -> [Asset] {
        var assets: [Asset] = []
        if SettingDataManager.shared.getHideSmallAssets() {
            assets = assetsInHideSmallMode
        } else {
            assets = self.assets
        }
        
        guard let enable = enable else {
            return assets
        }
        return assets.filter { (asset) -> Bool in
            asset.enable == enable
        }
    }
    
    func setAssets(newAssets: [Asset]) {
        let filteredAssets = newAssets.filter { (asset) -> Bool in
            return asset.symbol.trim() != ""
        }
        
        // If not assets are in the API response, return early.
        if filteredAssets.count == 0 {
            return
        }

        let sortedAssets = filteredAssets.sorted { (a, b) -> Bool in
            return a.balance > b.balance
        }

        totalCurrencyValue = 0
        for asset in sortedAssets {
            // If the price quote is nil, asset won't be updated. Please use getBalanceAndPriceQuote()
            if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: asset.symbol) {
                
                let currencyFormatter = NumberFormatter()
                currencyFormatter.locale = NSLocale.current
                currencyFormatter.usesGroupingSeparator = true
                currencyFormatter.numberStyle = .currency
                let formattedNumber = currencyFormatter.string(from: NSNumber(value: asset.balance * price)) ?? "\(asset.balance * price)"
                // asset.display = "$ " + String(formattedNumber.dropFirst())
                asset.display = formattedNumber
                
                totalCurrencyValue += asset.balance * price
                
                // If the asset is in the array, then replace it.
                if let index = assets.index(of: asset) {
                    assets[index] = asset
                } else {
                    assets.append(asset)
                    if currentAppWallet != nil && currentAppWallet!.assetSequence.index(of: asset.symbol) == nil {
                        currentAppWallet!.assetSequence.append(asset.symbol)
                    }
                }

                if let index = assetsInHideSmallMode.index(of: asset) {
                    assetsInHideSmallMode[index] = asset
                } else {
                    if asset.balance > 0.01 {
                        assetsInHideSmallMode.append(asset)
                        if currentAppWallet != nil && currentAppWallet!.assetSequenceInHideSmallAssets.index(of: asset.symbol) == nil {
                            currentAppWallet!.assetSequenceInHideSmallAssets.append(asset.symbol)
                        }
                    }
                }
            }
        }

        if currentAppWallet != nil {
            AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: currentAppWallet!)
        }
    }

    // TODO: Add filter by token.
    func getTransactions(txStatuses: [Transaction.TxStatus]? = nil) -> [Transaction] {
        guard let txStatuses = txStatuses else {
            return self.transactions
        }
        return transactions.filter { (transaction) -> Bool in
            txStatuses.contains(transaction.status)
        }
    }

    func exchange(at sourceIndex: Int, to destinationIndex: Int) {
        guard let currentAppWallet = currentAppWallet else {
            return
        }
        
        if SettingDataManager.shared.getHideSmallAssets() {
            if destinationIndex < assetsInHideSmallMode.count && sourceIndex < assetsInHideSmallMode.count {
                assetsInHideSmallMode.swapAt(sourceIndex, destinationIndex)
            }

            if destinationIndex < currentAppWallet.assetSequenceInHideSmallAssets.count && sourceIndex < currentAppWallet.assetSequenceInHideSmallAssets.count {
                currentAppWallet.assetSequenceInHideSmallAssets.swapAt(sourceIndex, destinationIndex)
            }
        } else {
            if destinationIndex < assets.count && sourceIndex < assets.count {
                assets.swapAt(sourceIndex, destinationIndex)
            }

            if destinationIndex < currentAppWallet.assetSequence.count && sourceIndex < currentAppWallet.assetSequence.count {
                currentAppWallet.assetSequence.swapAt(sourceIndex, destinationIndex)
            }
        }

        // Update the asset sequence to the local storage
        DispatchQueue.global(qos: .userInitiated).async {
            AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: currentAppWallet)
        }
    }
    
    func startGetBalance() {
        guard let wallet = currentAppWallet else {
            return
        }
        LoopringSocketIORequest.getBalance(owner: wallet.address)
    }
    
    func stopGetBalance() {
        guard let wallet = currentAppWallet else {
            return
        }
        LoopringSocketIORequest.stopBalance(owner: wallet.address)
    }
    
    func getTransactionsFromServer(asset: Asset, completionHandler: @escaping (_ transactions: [Transaction], _ error: Error?) -> Void) {
        guard let wallet = currentAppWallet else {
            return
        }
        LoopringAPIRequest.getTransactions(owner: wallet.address, symbol: asset.symbol, thxHash: nil, completionHandler: { (transactions, error) in
            guard error == nil && transactions != nil else {
                return
            }
            self.transactions = []
            for transaction in transactions! {
                self.transactions.append(transaction)
            }
            completionHandler(self.transactions, nil)
        })
    }

    // Socket IO: this func should be called every 10 secs when emitted
    func onBalanceResponse(json: JSON) {
        let tokensJsons = json["tokens"].arrayValue

        let mappedAssets = tokensJsons.map { (subJson) -> Asset in
            // print("CurrentAppWalletDataManager onBalanceResponse")
            // print(subJson)
            let asset = Asset(json: subJson)
            return asset
        }
        
        setAssets(newAssets: mappedAssets)

        print("received balance ................................... Assets count: \(mappedAssets.count)")
        NotificationCenter.default.post(name: .balanceResponseReceived, object: nil)
    }
    
    // JSON RPC
    func getBalanceAndPriceQuote(completionHandler: @escaping (_ assets: [Asset], _ error: Error?) -> Void) {
        guard currentAppWallet != nil else {
            return
        }
        
        var localAssets: [Asset] = []

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        LoopringAPIRequest.getBalance(owner: self.currentAppWallet!.address) { assets, error in
            print("receive LoopringAPIRequest.getBalance ...")
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            localAssets = assets
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        LoopringAPIRequest.getPriceQuote(currency: "USD", completionHandler: { (priceQuote, error) in
            print("receive LoopringAPIRequest.getPriceQuote ....")
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            PriceQuoteDataManager.shared.setPriceQuote(newPriceQuote: priceQuote!)
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
            self.setAssets(newAssets: localAssets)
            completionHandler(self.assets, nil)
        }
    }
}
