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
    private var trends: [Trend]
    private lazy var favoriteMarketKeys: [String] = self.getFavoriteMarketKeysFromLocal()
    
    private init() {
        markets = []
        trends = []
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
    
    func getTrends(market: String, interval: String = "1Hr") -> [Trend]? {
        var result: [Trend]? = nil
        result = self.trends.filter { (trend) -> Bool in
            return trend.market.lowercased() == market.lowercased() &&
            trend.intervals.lowercased() == interval.lowercased()
        }
        if result?.count == 0 {
            // TODO: how to handle here?
            self.getTrendsFromServer(market: market, interval: interval, completionHandler: { (trends, error) in
                guard error == nil else {
                    return
                }
                result = trends
            })
        }
        return result
    }
    
    func getTrendsFromServer(market: String, interval: String = "1Hr", completionHandler: @escaping (_ trends: [Trend]?, _ error: Error?) -> Void) {
        LoopringAPIRequest.getTrend(market: market, interval: interval, completionHandler: { (trends, error) in
            guard error == nil else {
                return
            }
            completionHandler(trends, nil)
        })
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
    
    // TODO: whether stop method is useful? Yes.
    func startGetTicker() {
        LoopringSocketIORequest.getTiker()
    }
    
    func startGetTrend(market: String, interval: String = "1Hr") {
        LoopringSocketIORequest.getTrend(market: market, interval: interval)
    }
    
    func onTickerResponse(json: JSON) {
        // TODO: Apply diff algorithm.
        markets = []
        // print(json)
        for subJson in json.arrayValue {
            if let market = Market(json: subJson) {
                markets.append(market)
            }
        }
        NotificationCenter.default.post(name: .tickerResponseReceived, object: nil)
    }
    
    func onTrendResponse(json: JSON) {
        // TODO: Apply diff algorithm.
        trends = []
        print(json)
        for subJson in json.arrayValue {
            let trend = Trend(json: subJson)
            print(DataUtil.convertToDate(trend.start, format: "HH:mm"))
            print(DataUtil.convertToDate(trend.end, format: "HH:mm"))
            trends.append(trend)
        }
        NotificationCenter.default.post(name: .trendResponseReceived, object: nil)
    }
}
