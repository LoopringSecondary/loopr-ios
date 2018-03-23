//
//  MarketDataManager.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class MarketDataManager {
    
    static let shared = MarketDataManager()
    
    private var markets: [Market]
    private lazy var favoriteMarketKeys: [String] = self.getFavoriteMarketKeysFromLocal()
    
    private init() {
        markets = []
    }
    
    // TODO:
    func updateMarket() {
        
    }

    func exchange(at sourceIndex: Int, to destinationIndex: Int) {
        if destinationIndex < markets.count && sourceIndex < markets.count {
            markets.swapAt(sourceIndex, destinationIndex)
            // Update the array in the disk
            updateFavoriteMarketKeysOnLocal()
        }
    }
    
    func getMarkets(type: MarketSwipeViewType = .all) -> [Market] {
        switch type {
        case .all:
            return markets
        case .favorite:
            return markets.filter({ (market) -> Bool in
                return favoriteMarketKeys.contains(market.description)
            })
        case .ETH:
            return markets.filter({ (market) -> Bool in
                // TODO: make sure
                return market.tradingPair.tradingA == "WETH" || market.tradingPair.tradingB == "WETH"
            })
        case .LRC:
            return markets.filter({ (market) -> Bool in
                // TODO: make sure
                return market.tradingPair.tradingA == "LRC" || market.tradingPair.tradingB == "LRC"
            })
        }
    }

    func getFavoriteMarketKeys() -> [String] {
        return favoriteMarketKeys
    }
    
    func getFavoriteMarketKeysFromLocal() -> [String] {
        let defaults = UserDefaults.standard
        if let favoriteMarkets = defaults.stringArray(forKey: UserDefaultsKeys.favoriteMarkets.rawValue) {
            return favoriteMarkets
        }
        return []
    }
    
    func updateFavoriteMarketKeysOnLocal() {
        let defaults = UserDefaults.standard
        defaults.set(favoriteMarketKeys, forKey: UserDefaultsKeys.favoriteMarkets.rawValue)
    }

    func setFavoriteMarket(market: Market) {
        // Update the array in the memory
        favoriteMarketKeys.append(market.description)
        
        // Update the array in the disk
        updateFavoriteMarketKeysOnLocal()
    }
    
    func removeFavoriteMarket(market: Market) {
        // Update the array in the memory
        favoriteMarketKeys = favoriteMarketKeys.filter { $0 != market.description }

        // Update the array in the disk
        updateFavoriteMarketKeysOnLocal()
    }
    
    // TODO: whether stop method is useful?
    func startGetTicker() {
        LoopringSocketIORequest.getTiker()
    }
    
    func onTickerResponse(json: JSON) {
        markets = []
        print(json)
        for subJson in json.arrayValue {
            if let market = Market(json: subJson) {
                let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: market.tradingPair.tradingA)
                market.display = price ?? 0
                markets.append(market)
            }
        }
        NotificationCenter.default.post(name: .tickerResponseReceived, object: nil)
    }
}
