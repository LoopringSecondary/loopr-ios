//
//  Market.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class Market: Equatable, CustomStringConvertible {
    
    var description: String
    
    final let tradingPair: TradingPair

    // TODO: Use random generators
    var balance: Double = 0
    var volumeInPast24: Double = 0
    
    init(tradingA: String, tradingB: String) {
        tradingPair = TradingPair(tradingA, tradingB)
        
        description = "\(tradingA) " + " / " + "\(tradingB)"
        
        balance = Double(arc4random_uniform(1000))
        volumeInPast24 = Double(arc4random_uniform(6)) * 100 + Double(arc4random_uniform(100))
    }
    
    func isFavorite() -> Bool {
        return MarketDataManager.shared.getFavoriteMarketKeys().contains(description)
    }

    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.tradingPair == rhs.tradingPair
    }

}
