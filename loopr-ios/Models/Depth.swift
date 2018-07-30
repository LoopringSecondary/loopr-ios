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

    let price: String
    let amountA: String
    let amountB: String
    
    init(market: String, price: String, amountA: String, amountB: String) {
        self.market = market
        self.price = price
        self.amountA = amountA
        self.amountB = amountB
    }
    
    init?(market: String, content: [String]) {
        if content.count != 3 {
            return nil
        }
        self.market = market
        self.price = content[0]
        self.amountA = content[1]
        self.amountB = content[2]
    }
}
