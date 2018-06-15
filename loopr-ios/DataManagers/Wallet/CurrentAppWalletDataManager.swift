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
    
    func setCurrentAppWallet(_ appWallet: AppWallet) {
        print("setCurrentAppWallet ...")
        let defaults = UserDefaults.standard
        defaults.set(appWallet.privateKey, forKey: UserDefaultsKeys.currentAppWallet.rawValue)
        currentAppWallet = appWallet
        
        // TODO: This needs to join TokenLists
        self.assetsInHideSmallMode = []
        self.assets = []
        self.transactions = []
        self.totalCurrencyValue = 0
        
        // Init assets using assetSequence in AppWallet
        for symbol in currentAppWallet!.getAssetSequence() {
            let asset = Asset(symbol: symbol)
            if let index = assets.index(of: asset) {
                assets[index] = asset
            } else {
                assets.append(asset)
            }
        }

        for symbol in currentAppWallet!.getAssetSequenceInHideSmallAssets() {
            let asset = Asset(symbol: symbol)
            if let index = assetsInHideSmallMode.index(of: asset) {
                assetsInHideSmallMode[index] = asset
            } else {
                assetsInHideSmallMode.append(asset)
            }
        }
        
        // Get nonce. It's a slow API request.
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()

        // Push a notification
        NotificationCenter.default.post(name: .appWalletDidUpdate, object: nil)
        
        startGetBalance()
    }
    
    func getCurrentAppWallet() -> AppWallet? {
        return currentAppWallet
    }

    func getTotalAsset() -> Double {
        return totalCurrencyValue
    }
    
    func getAsset(symbol: String) -> Asset? {
        let result: Asset? = nil
        for asset in self.assets {
            if asset.symbol.lowercased() == symbol.lowercased() {
                return asset
            }
        }
        return result
    }
    
    func getBalance(of token: String) -> Double? {
        if let asset = getAsset(symbol: token) {
            return asset.balance
        }
        return nil
    }
    
    func getTotalAssetCurrencyFormmat() -> String {
        return totalCurrencyValue.currency
    }

    func getAssets(enable: Bool? = nil) -> [Asset] {
        guard let enable = enable else {
            return self.assets
        }
        return assets.filter { (asset) -> Bool in
            asset.enable == enable
        }
    }
    
    func getAssets(isNotZero: Bool) -> [Asset] {
        return assets.filter({ (asset) -> Bool in
            asset.total > 0.001
        })
    }
    
    // Used in WalletViewController with hide small assets option
    func getAssetsWithHideSmallAssetsOption() -> [Asset] {
        if SettingDataManager.shared.getHideSmallAssets() {
            return self.assets.filter({ (asset) -> Bool in
                return TokenDataManager.shared.getTokenList().contains(asset.symbol) && asset.total > 0.01
            }).sorted(by: { (a, b) -> Bool in
                a.total > b.total
            })
        } else {
            return self.assets.filter({ (asset) -> Bool in
                return TokenDataManager.shared.getTokenList().contains(asset.symbol) || asset.balance > 0
            }).sorted(by: { (a, b) -> Bool in
                a.total > b.total
            })
        }
    }

    // TODO: we should simplify this function.
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
            if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
                let total = asset.balance * price
                asset.total = total
                asset.currency = total.currency
                totalCurrencyValue += total
                
                // If the asset is in the array, then replace it.
                if let index = assets.index(of: asset) {
                    assets[index] = asset
                } else {
                    assets.append(asset)
                    if currentAppWallet != nil && currentAppWallet!.getAssetSequence().index(of: asset.symbol) == nil {
                        currentAppWallet!.addAssetSequence(symbol: asset.symbol)
                    }
                }

                // Small assets
                if asset.total > 0.01 {
                    if let index = assetsInHideSmallMode.index(of: asset) {
                        assetsInHideSmallMode[index] = asset
                    } else {
                        assetsInHideSmallMode.append(asset)
                        if currentAppWallet != nil && currentAppWallet!.getAssetSequenceInHideSmallAssets().index(of: asset.symbol) == nil {
                            currentAppWallet!.addAssetSequenceInHideSmallAssets(symbol: asset.symbol)
                        }
                    }
                } else {
                    // If it's a small asset and also in assetsInHideSmallMode, remove it from assetsInHideSmallMode
                    if let index = assetsInHideSmallMode.index(of: asset) {
                        assetsInHideSmallMode.remove(at: index)
                    }
                }
                
                // non-zero assets
                if asset.balance > 0 {
                    print(asset.symbol)
                    TokenDataManager.shared.updateTokenList(tokenSymbol: asset.symbol, add: true)
                }
            }
        }
        
        // Remove small assets
        assetsInHideSmallMode = assetsInHideSmallMode.filter { (asset) -> Bool in
            return asset.total > 0.01
        }

        if currentAppWallet != nil {
            currentAppWallet!.assetSequenceInHideSmallAssets = assetsInHideSmallMode.filter { (asset) -> Bool in
                return asset.total > 0.01
            }.map({ (asset) -> String in
                return asset.symbol
            })
            print(currentAppWallet!.assetSequenceInHideSmallAssets)
            currentAppWallet!.totalCurrency = totalCurrencyValue
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
        LoopringSocketIORequest.endBalance()
    }
    
    func getTransactionsFromServer(asset: Asset, completionHandler: @escaping (_ transactions: [Transaction], _ error: Error?) -> Void) {
        guard let wallet = currentAppWallet else {
            return
        }
        LoopringAPIRequest.getTransactions(owner: wallet.address, symbol: asset.symbol, txHash: nil, pageSize: 50, completionHandler: { (transactions, error) in
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

    // TODO: only 19 tokens are returned.
    // Socket IO: this func should be called every 10 secs when emitted
    func onBalanceResponse(json: JSON) {
        let tokensJsons = json["tokens"].arrayValue
        let mappedAssets = tokensJsons.map { (subJson) -> Asset in
            let asset = Asset(json: subJson)
            print(asset.symbol)
            return asset
        }
        setAssets(newAssets: mappedAssets)
        print("received Assets count: \(mappedAssets.count)")
        NotificationCenter.default.post(name: .balanceResponseReceived, object: nil)
    }
    
    // JSON RPC
    func getBalanceAndPriceQuote(address: String, completionHandler: @escaping (_ assets: [Asset], _ error: Error?) -> Void) {
        print("getBalanceAndPriceQuote Current address: \(address)")
        
        var localAssets: [Asset] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        let currency = SettingDataManager.shared.getCurrentCurrency().name
        LoopringAPIRequest.getPriceQuote(currency: currency, completionHandler: { (priceQuote, error) in
            print("receive LoopringAPIRequest.getPriceQuote ....")
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            PriceDataManager.shared.setPriceQuote(newPriceQuote: priceQuote!)
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        LoopringAPIRequest.getBalance(owner: address) { assets, error in
            print("receive LoopringAPIRequest.getBalance ...")
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            localAssets = assets
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
            self.setAssets(newAssets: localAssets)
            completionHandler(self.assets, nil)
        }
    }
}
