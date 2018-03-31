//
//  AssetDataManager.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON
import BigInt

class AssetDataManager {

    static let shared = AssetDataManager()
    
    private var totalAsset: Double
    private var assets: [Asset]
    private var tokens: [Token]
    private var transactions: [Transaction]
    
    private init() {
        self.assets = []
        self.tokens = []
        self.transactions = []
        self.totalAsset = 0
        self.loadTokens()
    }
    
    // Get a list of tokens
    func getTokens() -> [Token] {
        return tokens
    }
    
    func getTotalAsset() -> Double {
        return totalAsset
    }
    
    func getTotalAssetCurrencyFormmat() -> String {
        let currentyFormatter = NumberFormatter()
        currentyFormatter.usesGroupingSeparator = true
        currentyFormatter.numberStyle = .currency
        let formattedNumber = currentyFormatter.string(from: NSNumber(value: totalAsset)) ?? "\(totalAsset)"
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
    
    func getTokenBySymbol(_ symbol: String) -> Token? {
        var result: Token? = nil
        for case let token in tokens where token.symbol.lowercased() == symbol.lowercased() {
            result = token
            break
        }
        return result
    }
    
    func exchange(at sourceIndex: Int, to destinationIndex: Int) {
        if destinationIndex < assets.count && sourceIndex < assets.count {
            assets.swapAt(sourceIndex, destinationIndex)
        }
    }
    
    // TODO: whether stop method is useful?
    func startGetBalance(_ owner: String) {
        LoopringSocketIORequest.getBalance(owner: owner)
    }
    
    func loadTokens() {
        loadTokensFromJson()
        loadTokensFromServer()
    }
    
    // load tokens from json file to avoid http request
    func loadTokensFromJson() {
        if let path = Bundle.main.path(forResource: "tokens", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let json = JSON(parseJSON: jsonString!)
            for subJson in json.arrayValue {
                let token = Token(json: subJson)
                tokens.append(token)
            }
        }
    }
    
    func loadTokensFromServer() {
        LoopringAPIRequest.getSupportedTokens { (tokens, error) in
            guard let tokens = tokens, error == nil else {
                return
            }
            for token in tokens {
                // Check if the token exists in self.tokens.
                if !self.tokens.contains(where: { (element) -> Bool in
                    return element.symbol.lowercased() == token.symbol.lowercased()
                }) {
                    self.tokens.append(token)
                }
            }
        }
    }
    
    func getContractAddressBySymbol(symbol: String) -> String? {
        if let token = getTokenBySymbol(symbol) {
            return token.protocol_value
        } else {
            return nil
        }
    }
    
    func getAmount(of symbol: String, from gweiAmount: String, to precision: Int = 4) -> Double? {
        var result: Double? = nil
        if gweiAmount.lowercased().starts(with: "0x") {
            let hexString = gweiAmount.dropFirst(2)
            let decString = BigUInt(hexString, radix: 16)!.description
            return getAmount(of: symbol, from: decString, to: precision)
        } else if let token = getTokenBySymbol(symbol) {
            var amount = gweiAmount
            if token.decimals >= amount.count {
                let prepend = String(repeating: "0", count: token.decimals - amount.count + 1)
                amount = prepend + amount
            }
            let offset = precision - token.decimals
            var index = amount.index(amount.endIndex, offsetBy: offset)
            amount.removeSubrange(index...)
            index = amount.index(amount.endIndex, offsetBy: -precision)
            amount.insert(".", at: index)
            result = Double(amount)
        }
        return result
    }
    
    func getTransactionsFromServer(owner: String, asset: Asset, completionHandler: @escaping (_ transactions: [Transaction], _ error: Error?) -> Void) {
        
        transactions = []
        let ownerx = "0x48ff2269e58a373120FFdBBdEE3FBceA854AC30A"
        
        LoopringAPIRequest.getTransactions(owner: ownerx, symbol: asset.symbol, thxHash: nil, completionHandler: { (transactions, error) in
            guard error == nil && transactions != nil else {
                return
            }
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
    
    // TODO: No used?
    func formatAsset(asset: inout Asset) {
        if let balance = getAmount(of: asset.symbol, from: asset.balance) {
            if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: asset.symbol) {
                asset.name = getTokenBySymbol(asset.symbol)?.source ?? "unknown token"
                asset.balance = balance.description
                
                let currentyFormatter = NumberFormatter()
                currentyFormatter.usesGroupingSeparator = true
                currentyFormatter.numberStyle = .currency
                let formattedNumber = currentyFormatter.string(from: NSNumber(value: balance * price)) ?? "\(balance * price)"
                asset.display = "$ " + String(formattedNumber.dropFirst())
                
                assets.append(asset)
                totalAsset += balance * price
            }
        }
    }
    
    // this func should be called every 10 secs when emitted
    func onBalanceResponse(json: JSON) {
        assets = []
        totalAsset = 0
        for subJson in json["tokens"].arrayValue {
            let asset = Asset(json: subJson)
            if let balance = getAmount(of: asset.symbol, from: asset.balance) {
                if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: asset.symbol) {
                    asset.name = getTokenBySymbol(asset.symbol)?.source ?? "unknown token"
                    asset.balance = balance.description

                    let currentyFormatter = NumberFormatter()
                    currentyFormatter.usesGroupingSeparator = true
                    currentyFormatter.numberStyle = .currency
                    let formattedNumber = currentyFormatter.string(from: NSNumber(value: balance * price)) ?? "\(balance * price)"
                    asset.display = "$ " + String(formattedNumber.dropFirst())

                    assets.append(asset)
                    totalAsset += balance * price
                }
            }
        }
        NotificationCenter.default.post(name: .balanceResponseReceived, object: nil)
    }
}
