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

    func getMarkets(type: MarketSwipeViewType = .all) -> [Market] {
        switch type {
        case .all:
            return markets
        case .favorite:
            return markets
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
        loopring_JSON_RPC.getSupportedMarket() { markets, error in
            self.markets = markets
            completionHandler(markets, error)
        }
    }

}
