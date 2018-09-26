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
    
    private var trends: [Trend]
    private var markets: [Market]
    private var currentAppWallet: AppWallet?
    
    private var favoriteSequence: [String]
    
    private init() {
        markets = []
        trends = []

        let defaults = UserDefaults.standard
        favoriteSequence = defaults.array(forKey: UserDefaultsKeys.favoriteSequence.rawValue) as? [String] ?? []
    }
    
    func isMarketsEmpty() -> Bool {
        return markets.isEmpty
    }

    func setMarkets(newMarkets: [Market]) {
        let filteredMarkets = newMarkets.filter { (market) -> Bool in
            return market.description != ""
        }
        self.markets = filteredMarkets
    }

    func getBalance(of pair: String) -> Double {
        var result: Double = 0
        for market in markets {
            if market.tradingPair.description.lowercased() == pair.lowercased() {
                result = market.balance
                break
            }
        }
        return result
    }
    
    func getTrends(market: String, interval: String = "1Hr") -> [Trend]? {
        var result: [Trend]?
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
    
    func getMarket(byTradingPair tradingPair: String) -> Market? {
        for case let market in self.markets where market.description.lowercased() == tradingPair.lowercased() {
            return market
        }
        return nil
    }
    
    func getMarketsWithoutReordered(type: MarketSwipeViewType = .all, tag: TickerTag = .all) -> [Market] {
        var result: [Market]
        switch type {
        case .favorite:
            result = markets.filter({ (market) -> Bool in
                return favoriteSequence.contains(market.description)
            })
        case .LRC:
            let sortedMarkets = markets.filter({ (market) -> Bool in
                return market.tradingPair.tradingB.uppercased() == "LRC"
            }).sorted { (a, b) -> Bool in
                return a.description < b.description
            }
            result = sortedMarkets
        case .ETH:
            let sortedMarkets = markets.filter({ (market) -> Bool in
                return market.tradingPair.tradingB.uppercased() == "ETH" || market.tradingPair.tradingB.uppercased() == "WETH"
            }).sorted { (a, b) -> Bool in
                return a.description < b.description
            }
            result = sortedMarkets
        case .USDT:
            let sortedMarkets = markets.filter({ (market) -> Bool in
                return market.tradingPair.tradingB.uppercased() == "USDT"
            }).sorted { (a, b) -> Bool in
                return a.description < b.description
            }
            result = sortedMarkets
        case .all:
            result = markets
        }
        
        // If it's favorite type, return all with favorite.
        if tag != .all && type != .favorite {
            result = result.filter({ (market) -> Bool in
                return market.tag == tag
            })
        }
        return result
    }

    func getFavoriteMarketKeys() -> [String] {
        return favoriteSequence
    }

    func setFavoriteMarket(market: Market) {
        favoriteSequence.append(market.description)
        UserDefaults.standard.set(favoriteSequence, forKey: UserDefaultsKeys.favoriteSequence.rawValue)
    }
    
    func removeFavoriteMarket(market: Market) {
        favoriteSequence = favoriteSequence.filter { $0 != market.description }
        UserDefaults.standard.set(favoriteSequence, forKey: UserDefaultsKeys.favoriteSequence.rawValue)
    }
    
    func startGetTicker() {
        LoopringSocketIORequest.getTiker()
    }
    
    func stopGetTicker() {
        LoopringSocketIORequest.endTicker()
    }
    
    func startGetTrend(market: String, interval: String = "1Hr") {
        LoopringSocketIORequest.getTrend(market: market, interval: interval)
    }
    
    func stopGetTrend() {
        LoopringSocketIORequest.endTrend()
    }
    
    func onTickerResponse(json: JSON) {
        var newMarkets: [Market] = []
        for subJson in json.arrayValue {
            if let market = Market(json: subJson) {
                newMarkets.append(market)
            }
        }
        setMarkets(newMarkets: newMarkets)
        NotificationCenter.default.post(name: .tickerResponseReceived, object: nil)
    }
    
    func onTrendResponse(json: JSON) {
        trends = []
        for subJson in json.arrayValue {
            let trend = Trend(json: subJson)
            trends.append(trend)
        }
        NotificationCenter.default.post(name: .trendResponseReceived, object: nil)
    }
}
