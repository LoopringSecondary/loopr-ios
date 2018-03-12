//
//  PriceQuote.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class PriceQuote {
    
    class Token {
        let price: Double
        let symbol: String
        
        init(_ price: JSON, _ symbol: JSON) {
            self.price = price.doubleValue
            self.symbol = symbol.stringValue
        }
    }
    
    let currency: String
    var tokens: [Token]
    
    init(json: JSON) {
        self.currency = json["currency"].stringValue
        self.tokens = []
        for item in json["tokens"].arrayValue {
            let token = Token(item["price"], item["symbol"])
            self.tokens.append(token)
        }
    }
}
