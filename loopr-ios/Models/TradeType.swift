//
//  TradeType.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

enum TradeType: CustomStringConvertible {
    case buy
    case sell
    
    var description: String {
        switch self {
        case .buy: return LocalizedString("Buy", comment: "")
        case .sell: return LocalizedString("Sell", comment: "")
        }
    }
}
