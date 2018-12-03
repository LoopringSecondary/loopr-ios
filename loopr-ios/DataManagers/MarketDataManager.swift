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
        
        // If users have never set or remove favorite market pair, use the default values "LRC-WETH"
        if defaults.array(forKey: UserDefaultsKeys.favoriteSequence.rawValue) as? [String] == nil {
            favoriteSequence = ["LRC-WETH"]
            UserDefaults.standard.set(favoriteSequence, forKey: UserDefaultsKeys.favoriteSequence.rawValue)
        } else {
            favoriteSequence = defaults.array(forKey: UserDefaultsKeys.favoriteSequence.rawValue) as? [String] ?? []
        }
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
    
    func getDecimals(tokenSymbol: String) -> Int {
        let filteredMarkets = markets.filter { (market) -> Bool in
            return market.description == "\(tokenSymbol)-USDT"
        }
        guard filteredMarkets.count > 0 else {
            return 8
        }
        
        return filteredMarkets[0].decimals
    }
    
    func getDecimals(tradingPair: String) -> Int {
        let filteredMarkets = markets.filter { (market) -> Bool in
            return market.description == tradingPair
        }
        guard filteredMarkets.count > 0 else {
            return 8
        }
        
        return filteredMarkets[0].decimals
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
    
    func getTrendsFromServer(market: String, trendRange: TrendRange, completionHandler: @escaping (_ trends: [Trend], _ error: Error?) -> Void) {
        LoopringAPIRequest.getTrend(market: market, interval: trendRange.getTrendInterval().description, completionHandler: { (trends, error) in
            guard error == nil else {
                return
            }
            
            if trends.count >= trendRange.getCount() {
                completionHandler(Array(trends[0..<trendRange.getCount()].reversed()), nil)
            } else {
                completionHandler(trends.reversed(), nil)
            }
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
        case .TUSD:
            let sortedMarkets = markets.filter({ (market) -> Bool in
                return market.tradingPair.tradingB.uppercased() == "TUSD"
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
    
    // TODO: deprecate socker io to get trends
    func startGetTrend(market: String, interval: String) {
        LoopringSocketIORequest.getTrend(market: market, interval: interval)
    }
    
    func stopGetTrend() {
        LoopringSocketIORequest.endTrend()
    }
    
    func onTrendResponse(json: JSON) {
        /*
        trends = []
        for subJson in json.arrayValue {
            let trend = Trend(json: subJson)
            trends.append(trend)
        }
        NotificationCenter.default.post(name: .trendResponseReceived, object: nil)
        */
    }
}
