//
//  AssetDataManager.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class AssetDataManager {

    static let shared = AssetDataManager()
    
    private var totalAsset: Double
    private var assets: [Asset]
    private var tokens: [Token]
    
    private init() {
        self.assets = []
        self.tokens = []
        self.totalAsset = 0
        self.loadTokensFromJson()
    }
    
    func getTokens() -> [Token] {
        return tokens
    }
    
    func getAssets() -> [Asset] {
        return assets
    }
    
    func getTotalAsset() -> Double {
        return totalAsset
    }
    
    func getTokenNameBySymbol(_ symbol: String) -> String? {
        var result: String? = nil
        for case let token in tokens where token.symbol.lowercased() == symbol.lowercased() {
            result = token.source
            break
        }
        return result
    }
    
    func exchange(at sourceIndex: Int, to destinationIndex: Int) {
        if destinationIndex < assets.count && sourceIndex < assets.count {
            assets.swapAt(sourceIndex, destinationIndex)
        }
    }
    
    // MARK: whether stop method is useful?
    func startGetBalance(_ owner: String) {
        LoopringSocketIORequest.getBalance(owner: owner)
    }
    
    // load tokens esp. their names from json file to avoid http request
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
    
    // this func should be called every 10 secs when emitted
    func onBalanceResponse(json: JSON) {
        
        print(json)
        
        assets = []
        totalAsset = 0
        for subJson in json["tokens"].arrayValue {
            let asset = Asset(json: subJson)
            if let price = PriceQuoteDataManager.shared.getPriceQuote() {
                for case let priceToken in price.tokens where priceToken.symbol.lowercased() == asset.symbol.lowercased() {
                    if let balance = Double(asset.balance) {
                        asset.display = balance * priceToken.price
                        asset.icon = UIImage(named: asset.symbol) ?? nil
                        asset.name = getTokenNameBySymbol(asset.symbol) ?? "unknown"
                        totalAsset += asset.display
                    }
                }
            }
            assets.append(asset)
        }
    }
}
