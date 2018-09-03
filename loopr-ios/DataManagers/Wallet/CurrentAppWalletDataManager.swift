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
    
    private init() {
        self.assets = []
        self.assetsInHideSmallMode = []
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
        
        // Update websocket
        startGetBalance()
        
        // TODO: This needs to join TokenLists
        self.assetsInHideSmallMode = []
        self.assets = []
        self.totalCurrencyValue = appWallet.totalCurrency

        PartnerDataManager.shared.createPartner()

        // Get nonce. It's a slow API request.
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()

        // Publish a notification to update UI
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .currentAppWalletSwitched, object: nil)
        }
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
            asset.total > 0.001 || asset.balance > 0.01
        })
    }

    // Used in WalletViewController with hide small assets option
    func getAssetsWithHideSmallAssetsOption() -> [Asset] {
        print(currentAppWallet!.getTokenList())
        print(currentAppWallet!.getManuallyDisabledTokenList())
        for tokenSymbol in currentAppWallet!.getTokenList() {
            if let token = TokenDataManager.shared.getTokenBySymbol(tokenSymbol) {
                let newAsset = Asset(token: token)
                if !self.assets.contains(newAsset) {
                    self.assets.append(newAsset)
                }
            }
        }
        
        return self.assets.filter({ (asset) -> Bool in
            return currentAppWallet!.getTokenList().contains(asset.symbol) || asset.balance > 0.001
        }).filter({ (asset) -> Bool in
            // Hide tokens when users manually hide tokens in the token list view.
            return !currentAppWallet!.getManuallyDisabledTokenList().contains(asset.symbol)
        }).sorted(by: { (a, b) -> Bool in
            if a.symbol == "ETH" || b.symbol == "ETH" {
                return a.symbol == "ETH"
            } else if a.symbol == "WETH" || b.symbol == "WETH" {
                return a.symbol == "WETH"
            } else if a.symbol == "LRC" || a.symbol == "LRC" {
                return a.symbol == "LRC"
            } else if a.total != b.total {
                return a.total > b.total
            } else if a.balance != b.balance {
                return a.balance > b.balance
            } else {
                return a.symbol < b.symbol
            }
        })
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
        
        totalCurrencyValue = 0
        for asset in filteredAssets {
            // If the price quote is nil, asset won't be updated. Please use getBalanceAndPriceQuote()
            if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
                let total = asset.balance * price
                asset.total = total
                asset.currency = total.currency
                totalCurrencyValue += total
                
                // non-zero assets
                if asset.balance > 0 {
                    print(asset.symbol)
                    currentAppWallet!.updateTokenList([asset.symbol], add: true)
                }
            }
        }
        
        // Update assets
        self.assets = newAssets
        
        // Remove small assets
        assetsInHideSmallMode = assetsInHideSmallMode.filter { (asset) -> Bool in
            return asset.total > 0.01
        }
        
        if currentAppWallet != nil {
            AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: currentAppWallet!)
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
    
    func getTransactionsFromServer(asset: Asset, pageIndex: UInt, pageSize: UInt = 50, completionHandler: @escaping (_ transactions: [Transaction], _ error: Error?) -> Void) {
        guard let wallet = currentAppWallet else {
            return
        }
        LoopringAPIRequest.getTransactions(owner: wallet.address, symbol: asset.symbol, txHash: nil, pageIndex: pageIndex,  pageSize: pageSize, completionHandler: { (transactions, error) in
            guard error == nil, let transactions = transactions else {
                return
            }
            completionHandler(transactions, nil)
        })
    }
    
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
    func getBalanceAndPriceQuote(getPrice: Bool, completionHandler: @escaping (_ assets: [Asset], _ error: Error?) -> Void) {
        let address = self.currentAppWallet!.address
        print("getBalanceAndPriceQuote Current address: \(address)")
        
        var localAssets: [Asset] = []
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        if getPrice {
            let currency = SettingDataManager.shared.getCurrentCurrency().name
            LoopringAPIRequest.getPriceQuote(currency: currency, completionHandler: { (priceQuote, error) in
                print("receive LoopringAPIRequest.getPriceQuote ....")
                guard error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                PriceDataManager.shared.setPriceQuote(newPriceQuote: priceQuote!)
                
                LoopringAPIRequest.getBalance(owner: address) { assets, error in
                    print("receive LoopringAPIRequest.getBalance ...")
                    guard error == nil else {
                        print("error=\(String(describing: error))")
                        return
                    }
                    localAssets = assets
                    dispatchGroup.leave()
                }
            })
        } else {
            LoopringAPIRequest.getBalance(owner: address) { assets, error in
                print("receive LoopringAPIRequest.getBalance ...")
                guard error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                localAssets = assets
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
            self.setAssets(newAssets: localAssets)
            completionHandler(self.assets, nil)
        }
    }
}
