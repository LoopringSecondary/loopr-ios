//
//  Depth.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum ErrorType: Error {
    case EmptyProperty
    case InvalidValue
}

class Depth {
    
    let market: String

    let unit: String
    let amount: String
    let total: String
    
    init(market: String, unit: String, amount: String, total: String) {
        self.market = market
        self.unit = unit
        self.amount = amount
        self.total = total
    }
    
    init?(market: String, content: [String]) {
        if content.count != 3 {
            return nil
        }
        self.market = market
        self.unit = content[0]
        self.amount = content[1]
        self.total = content[2]
    }
}
