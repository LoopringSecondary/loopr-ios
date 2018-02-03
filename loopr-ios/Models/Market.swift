//
//  Market.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class Market: CustomStringConvertible {
    
    var description: String
    
    final let tradingPair: TradingPair
    
    init(tradingA: String, tradingB: String) {
        tradingPair = TradingPair(tradingA, tradingB)
        
        description = "\(tradingA) " + " / " + "\(tradingB)"
    }

}
