//
//  Token.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Token {

    let symbol: String
    let source: String
    let isMarket: Bool
    let decimals: Int
    let protocol_value: String
    let deny: Bool

    init(json: JSON) {
        self.symbol = json["Symbol"].stringValue
        self.source = json["Source"].stringValue
        self.isMarket = json["IsMarket"].boolValue
        self.decimals = json["Decimals"].intValue
        self.protocol_value = json["Protocol"].stringValue
        self.deny = json["Deny"].boolValue
    }
}
