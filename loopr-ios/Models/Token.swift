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
    var balance: String
    var allowance: String
    var display: Double
    
    init(json: JSON) {
        self.display = 0
        self.symbol = json["symbol"].stringValue
        self.balance = json["balance"].stringValue
        self.allowance = json["allowance"].stringValue
    }
}
