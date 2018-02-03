//
//  TradingPair.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class TradingPair: Equatable {

    final let tradingA: String
    final let tradingB: String
    
    init(_ tradingA: String, _ tradingB: String) {
        self.tradingA = tradingA
        self.tradingB = tradingB
    }

    static func ==(lhs: TradingPair, rhs: TradingPair) -> Bool {
        if ((lhs.tradingA == rhs.tradingA && lhs.tradingB == rhs.tradingB) || (lhs.tradingA == rhs.tradingB && lhs.tradingB == rhs.tradingA)) {
            return true
        } else {
            return false
        }
    }
    
}
