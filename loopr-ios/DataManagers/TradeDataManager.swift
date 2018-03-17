//
//  TradeDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class TradeDataManager {
    
    static let shared = TradeDataManager()
    
    var state: OrderTradeState
    
    var type: TradeType = .buy

    var tokenS: Token
    var tokenB: Token

    private init() {
        state = .empty
        tokenS = Token(symbol: "ETH") ?? Token(symbol: "ETH")!
        tokenB = Token(symbol: "LRC") ?? Token(symbol: "LRC")!
    }

    func clear() {
        state = .empty
    }
    
    func changeTokenS(_ token: Token) {
        tokenS = token
    }

    func changeTokenB(_ token: Token) {
        tokenB = token
    }

}
