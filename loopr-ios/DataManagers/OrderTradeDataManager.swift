//
//  OrderTradeDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrderTradeDataManager {
    
    static let shared = OrderTradeDataManager()
    
    var state: OrderTradeState
    
    var type: TradeType = .buy
    var tradingPairA: String = "ETH"
    var tradingPairB: String = "LRC"
    
    private init() {
        state = .empty
    }

    func clear() {
        state = .empty
    }
}
