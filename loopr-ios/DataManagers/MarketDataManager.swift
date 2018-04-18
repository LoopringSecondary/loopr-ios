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
    
    private var lrcSequence: [String]
    private var wethSequence: [String]
    private var favoriteSequence: [String]
    private var allSequence: [String]
    
    private init() {
        markets = []
        trends = []
        lrcSequence = []
        wethSequence = []
        favoriteSequence = []
        allSequence = []
    }

    func setMarkets(newMarkets: [Market], type: MarketSwipeViewType = .all) {
        let filteredMarkets = newMarkets.filter { (market) -> Bool in
            return market.description != ""
        }
        switch type {
        case .favorite:
            let markets = filteredMarkets.filter({ (market) -> Bool in
                return favoriteSequence.contains(market.description)
            })
            for market in markets {
                if let index = favoriteSequence.index(of: market.description) {
                    favoriteSequence[index] = market.description
                }
            }
        case .LRC:
            let sortedMarkets = filteredMarkets.filter({ (market) -> Bool in
                return market.tradingPair.tradingB.uppercased() == "LRC"
            }).sorted { (a, b) -> Bool in
                return a.description < b.description
            }
            for market in sortedMarkets {
                if let index = lrcSequence.index(of: market.description) {
                    lrcSequence[index] = market.description
                } else {
                    lrcSequence.append(market.description)
                }
            }
            updateMarketKeysOnLocal(type: .LRC)
        case .ETH:
            let sortedMarkets = filteredMarkets.filter({ (market) -> Bool in
                return market.tradingPair.tradingB.uppercased() == "ETH" || market.tradingPair.tradingB.uppercased() == "WETH"
            }).sorted { (a, b) -> Bool in
                return a.description < b.description
            }
            for market in sortedMarkets {
                if let index = wethSequence.index(of: market.description) {
                    wethSequence[index] = market.description
                } else {
                    wethSequence.append(market.description)
                }
            }
            updateMarketKeysOnLocal(type: .ETH)
        case .all:
            let sortedMarkets = filteredMarkets.sorted(by: { (a, b) -> Bool in
                return a.description < b.description
            })
            self.markets = sortedMarkets
            for market in sortedMarkets {
                if let index = allSequence.index(of: market.description) {
                    allSequence[index] = market.description
                } else {
                    allSequence.append(market.description)
                }
            }
            updateMarketKeysOnLocal(type: .all)
        }
    }
    
    func updateMarketKeysOnLocal(type: MarketSwipeViewType) {
        var key: String = ""
        var value: [String] = []
        let defaults = UserDefaults.standard
        switch type {
        case .LRC:
            value = self.lrcSequence
            key = UserDefaultsKeys.lrcSequence.rawValue
        case .ETH:
            value = self.wethSequence
            key = UserDefaultsKeys.wethSequence.rawValue
        case .favorite:
            value = self.favoriteSequence
            key = UserDefaultsKeys.favoriteSequence.rawValue
        case .all:
            value = self.allSequence
            key = UserDefaultsKeys.allSequence.rawValue
        }
        defaults.set(value, forKey: key)
    }

    func exchange(at sourceIndex: Int, to destinationIndex: Int, type: MarketSwipeViewType) {
        switch type {
        case .favorite:
            if destinationIndex < favoriteSequence.count && sourceIndex < favoriteSequence.count {
                favoriteSequence.swapAt(sourceIndex, destinationIndex)
                updateMarketKeysOnLocal(type: .favorite)
            }
        case .LRC:
            if destinationIndex < lrcSequence.count && sourceIndex < lrcSequence.count {
                lrcSequence.swapAt(sourceIndex, destinationIndex)
                updateMarketKeysOnLocal(type: .LRC)
            }
        case .ETH:
            if destinationIndex < wethSequence.count && sourceIndex < wethSequence.count {
                wethSequence.swapAt(sourceIndex, destinationIndex)
                updateMarketKeysOnLocal(type: .ETH)
            }
        case .all:
            if destinationIndex < allSequence.count && sourceIndex < allSequence.count {
                allSequence.swapAt(sourceIndex, destinationIndex)
                updateMarketKeysOnLocal(type: .all)
            }
        }
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
            allSequence = getMarketKeysFromLocal(type: .all)
            return markets.sorted(by: { allSequence.index(of: $0.description)! < allSequence.index(of: $1.description)!
            })
        case .favorite:
            favoriteSequence = getMarketKeysFromLocal(type: .favorite)
            return markets.filter({ favoriteSequence.contains($0.description)
            }).sorted(by: { favoriteSequence.index(of: $0.description)! < favoriteSequence.index(of: $1.description)!
            })
        case .ETH:
            wethSequence = getMarketKeysFromLocal(type: .ETH)
            return markets.filter({ wethSequence.contains($0.description)
            }).sorted(by: { wethSequence.index(of: $0.description)! < wethSequence.index(of: $1.description)!
            })
        case .LRC:
            lrcSequence = getMarketKeysFromLocal(type: .LRC)
            return markets.filter({ lrcSequence.contains($0.description)
            }).sorted(by: { lrcSequence.index(of: $0.description)! < lrcSequence.index(of: $1.description)!
            })
        }
    }

    func getFavoriteMarketKeys() -> [String] {
        return favoriteSequence
    }
    
    func getMarketKeysFromLocal(type: MarketSwipeViewType) -> [String] {
        var key: String
        let defaults = UserDefaults.standard
        switch type {
        case .LRC:
            key = UserDefaultsKeys.lrcSequence.rawValue
        case .ETH:
            key = UserDefaultsKeys.wethSequence.rawValue
        case .favorite:
            key = UserDefaultsKeys.favoriteSequence.rawValue
        case .all:
            key = UserDefaultsKeys.allSequence.rawValue
        }
        if let markets = defaults.stringArray(forKey: key) {
            return markets
        }
        return []
    }
    
    func setFavoriteMarket(market: Market) {
        // Update the array in the memory
        favoriteSequence.append(market.description)
        // Update the array in the disk
        updateMarketKeysOnLocal(type: .favorite)
    }
    
    func removeFavoriteMarket(market: Market) {
        // Update the array in the memory
        favoriteSequence = favoriteSequence.filter { $0 != market.description }
        // Update the array in the disk
        updateMarketKeysOnLocal(type: .favorite)
    }
    
    // TODO: whether stop method is useful? Yes.
    func startGetTicker() {
        LoopringSocketIORequest.getTiker()
    }
    
    func startGetTrend(market: String, interval: String = "1Hr") {
        LoopringSocketIORequest.getTrend(market: market, interval: interval)
    }
    
    func onTickerResponse(json: JSON) {
        /*
        var newMarkets: [Market] = []
        for subJson in json.arrayValue {
            
            // TODO: This is a very expensive calls.
            if let market = Market(json: subJson) {
                newMarkets.append(market)
            }
        }
        setMarkets(newMarkets: newMarkets)
        NotificationCenter.default.post(name: .tickerResponseReceived, object: nil)
        */
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
