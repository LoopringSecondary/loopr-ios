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

    private var assets: [Asset]
    
    private var transactions: [Transaction]
    
    private init() {
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
        let defaults = UserDefaults.standard
        defaults.set(appWallet.privateKey, forKey: UserDefaultsKeys.currentAppWallet.rawValue)
        currentAppWallet = appWallet
        
        // Init assets using assetSequence in AppWallet
        for symbol in currentAppWallet!.assetSequence {
            let asset = Asset(symbol: symbol)
            assets.append(asset)
        }
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
        guard let enable = enable else {
            return self.assets
        }
        return assets.filter { (asset) -> Bool in
            asset.enable == enable
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

        if destinationIndex < assets.count && sourceIndex < assets.count {
            assets.swapAt(sourceIndex, destinationIndex)
        }
        
        if destinationIndex < currentAppWallet.assetSequence.count && sourceIndex < currentAppWallet.assetSequence.count {
            currentAppWallet.assetSequence.swapAt(sourceIndex, destinationIndex)
        }
        
        // Update the asset sequence to the local storage
        AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: currentAppWallet)
    }
    
    // TODO: whether stop method is useful?
    func startGetBalance(_ owner: String) {
        LoopringSocketIORequest.getBalance(owner: owner)
    }
    
    // TODO: Why precision is 4?
    func getAmount(of symbol: String, from gweiAmount: String, to precision: Int = 4) -> Double? {
        var result: Double? = nil
        // hex string
        if gweiAmount.lowercased().starts(with: "0x") {
            let hexString = gweiAmount.dropFirst(2)
            let decString = BigUInt(hexString, radix: 16)!.description
            return getAmount(of: symbol, from: decString, to: precision)
        } else if let token = TokenDataManager.shared.getTokenBySymbol(symbol) {
            var amount = gweiAmount
            guard token.decimals < 100 else {
                return result
            }
            if token.decimals >= amount.count {
                let prepend = String(repeating: "0", count: token.decimals - amount.count + 1)
                amount = prepend + amount
            }
            /*
            let offset = precision - token.decimals
            var index = amount.index(amount.endIndex, offsetBy: offset)
            amount.removeSubrange(index...)
            */
            let index = amount.index(amount.endIndex, offsetBy: -token.decimals)
            amount.insert(".", at: index)
            result = Double(amount)
        }
        return result
    }
    
    func getTransactionsFromServer(owner: String, asset: Asset, completionHandler: @escaping (_ transactions: [Transaction], _ error: Error?) -> Void) {
        LoopringAPIRequest.getTransactions(owner: owner, symbol: asset.symbol, thxHash: nil, completionHandler: { (transactions, error) in
            guard error == nil && transactions != nil else {
                return
            }
            self.transactions = []
            for transaction in transactions! {
                if let value = self.getAmount(of: transaction.symbol, from: transaction.value) {
                    if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: asset.symbol) {
                        transaction.value = value.description
                        transaction.display = value * price
                        self.transactions.append(transaction)
                    }
                }
            }
            completionHandler(self.transactions, nil)
        })
    }

    // this func should be called every 10 secs when emitted
    func onBalanceResponse(json: JSON) {
        // assets = []
        totalCurrencyValue = 0
        let tokensJsons = json["tokens"].arrayValue

        let mappedAssets = tokensJsons.map { (subJson) -> Asset in
            print("CurrentAppWalletDataManager onBalanceResponse")
            print(subJson)
            let asset = Asset(json: subJson)
            return asset
        }
        
        let filteredAssets = mappedAssets.filter { (asset) -> Bool in
            return asset.symbol != ""
        }

        let sortedAssets = filteredAssets.sorted { (a, b) -> Bool in
            return a.balance > b.balance
        }

        for asset in sortedAssets {
            if let balance = getAmount(of: asset.symbol, from: asset.balance) {
                if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: asset.symbol) {
                    asset.name = TokenDataManager.shared.getTokenBySymbol(asset.symbol)?.source ?? "unknown token"
                    asset.balance = balance.description

                    let currencyFormatter = NumberFormatter()
                    currencyFormatter.locale = NSLocale.current
                    currencyFormatter.usesGroupingSeparator = true
                    currencyFormatter.numberStyle = .currency
                    let formattedNumber = currencyFormatter.string(from: NSNumber(value: balance * price)) ?? "\(balance * price)"
                    // asset.display = "$ " + String(formattedNumber.dropFirst())
                    asset.display = formattedNumber

                    // If the asset is in the array, then replace it.
                    if let index = assets.index(of: asset) {
                        assets[index] = asset
                        totalCurrencyValue += balance * price

                    } else {
                        // If the asset is not in the array and the balance is 0, then skip it.
                        if asset.balance != "0" {
                            assets.append(asset)
                            if currentAppWallet != nil {
                                currentAppWallet!.assetSequence.append(asset.symbol)
                            }
                            totalCurrencyValue += balance * price
                        }
                    }
                }
            }
        }
        
        if currentAppWallet != nil {
            AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: currentAppWallet!)
        }
        NotificationCenter.default.post(name: .balanceResponseReceived, object: nil)
    }
}
