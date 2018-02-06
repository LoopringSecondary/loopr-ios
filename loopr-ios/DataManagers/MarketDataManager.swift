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
    
    func getMarketsFromServer(completionHandler: @escaping (_ market: [Market], _ error: Error?) -> Void) {
        JSON_RPC.getSupportedMarket() { markets, error in
            self.markets = markets
            completionHandler(markets, error)
        }
    }

}
