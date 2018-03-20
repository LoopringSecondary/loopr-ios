//
//  Ticker.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/19.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Ticker {
    
    let exchange: String
    let market: String
    let open: Double
    let amount: Double
    let vol: Double
    let interval: String
    let low: Double
    let close: Double
    let buy: String
    let change: String
    let high: Double
    let sell: String
    let last: Double

	init(json: JSON) {
        self.exchange = json["exchange"].stringValue
        self.market = json["exchange"].stringValue
        self.open = json["exchange"].doubleValue
        self.amount = json["exchange"].doubleValue
        self.vol = json["exchange"].doubleValue
        self.interval = json["exchange"].stringValue
        self.low = json["exchange"].doubleValue
        self.close = json["exchange"].doubleValue
        self.buy = json["exchange"].stringValue
        self.change = json["exchange"].stringValue
        self.high = json["exchange"].doubleValue
        self.sell = json["exchange"].stringValue
        self.last = json["exchange"].doubleValue
	}

}
