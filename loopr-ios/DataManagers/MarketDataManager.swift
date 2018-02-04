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
    
    private var markets: [Market]
    
    private init() {
        markets = []
    }
    
    func getMarkets() -> [Market] {
        return markets
    }
    
    func generateMockData() {
        markets = []
        
        let market1 = Market(tradingA: "ZRX", tradingB: "ETH")
        markets.append(market1)

        let market2 = Market(tradingA: "REP", tradingB: "ETH")
        markets.append(market2)
        
        let market3 = Market(tradingA: "OMG", tradingB: "ETH")
        markets.append(market3)
        
        let market4 = Market(tradingA: "RDN", tradingB: "ETH")
        markets.append(market4)
    }
}
