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
    
    class Content {
        let unit: String
        let amount: String
        let total: String
        
        init(unit: String, amount: String, total: String) {
            self.unit = unit
            self.amount = amount
            self.total = total
        }
        
        init(content: [String]) {
            if content.count != 3 {
                // TODO: kenshin
            }
            self.unit = content[0]
            self.amount = content[1]
            self.total = content[2]
        }
    }
    
    var buy: [Content]
    var sell: [Content]
    
    init(buyOrders: [[String]], sellOrders: [[String]]) {

        self.buy = [Content]()
        self.sell = [Content]()
        for buyOrder in buyOrders {
            let buy = Content(content: buyOrder)
            self.buy.append(buy)
        }
        for sellOrder in sellOrders {
            let sell = Content(content: sellOrder)
            self.sell.append(sell)
        }
    }
}
