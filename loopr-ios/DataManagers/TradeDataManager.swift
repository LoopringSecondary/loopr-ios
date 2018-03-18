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
    
    var amountTokenS: Double = 0.0
    var amountTokenB: Double = 0.0

    private init() {
        state = .empty
        
        // Get TokenS and TokenB from UserDefaults
        let defaults = UserDefaults.standard

        var tokenS: Token? = nil
        if let symbol = defaults.string(forKey: UserDefaultsKeys.tradeTokenS.rawValue) {
            tokenS = Token(symbol: symbol)
        }
        self.tokenS = tokenS ?? Token(symbol: "ETH")!
        
        var tokenB: Token? = nil
        if let symbol = defaults.string(forKey: UserDefaultsKeys.tradeTokenB.rawValue) {
            tokenB = Token(symbol: symbol)
        }
        self.tokenB = tokenB ?? Token(symbol: "LRC")!
    }

    func clear() {
        state = .empty
        
    }

    func changeTokenS(_ token: Token) {
        tokenS = token
        let defaults = UserDefaults.standard
        defaults.set(token.symbol, forKey: UserDefaultsKeys.tradeTokenS.rawValue)
    }

    func changeTokenB(_ token: Token) {
        tokenB = token
        let defaults = UserDefaults.standard
        defaults.set(token.symbol, forKey: UserDefaultsKeys.tradeTokenB.rawValue)
    }

}
