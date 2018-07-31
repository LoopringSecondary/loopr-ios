//
//  MarketTradeHistoryDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class MarketTradeHistoryDataManager {
    
    static let shared = MarketTradeHistoryDataManager()
    
    var market: String?
    private var orderFills: [OrderFill] = []
    
    private init() {
    }
    
    func getTrades() -> [OrderFill] {
        return orderFills
    }
    
    func getTradeHistoryFromServer(market: String, completionHandler: @escaping (_ orderFills: [OrderFill], _ error: Error?) -> Void) {
        LoopringAPIRequest.getLatestFills(market: market, side: "buy", completionHandler: { (orderFills, error) in
            print(orderFills?.count)
            guard orderFills != nil && error == nil else { return }
            self.market = market
            self.orderFills = orderFills!
            completionHandler(self.orderFills, nil)
        })
    }

}
