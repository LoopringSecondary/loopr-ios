//
//  MarketDataManager.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class MarketDataManager {
    
    static let shared = MarketDataManager()
    
    private lazy var favoriteMarketKeys: [String] = self.getFavoriteMarketKeysFromLocal()
    private var markets: [Market]
    
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
                return market.tradingPair.tradingA == "WETH" || market.tradingPair.tradingB == "WETH"
            })
        case .LRC:
            return markets.filter({ (market) -> Bool in
                return market.tradingPair.tradingA == "LRC" || market.tradingPair.tradingB == "LRC"
            })
        }
    }

    func getMarketsFromServer(completionHandler: @escaping (_ market: [Market], _ error: Error?) -> Void) {
        LoopringAPIRequest.getSupportedMarket(completionHandler: { markets, error in
            self.markets = markets!
            completionHandler(markets!, error)
        })
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

}
