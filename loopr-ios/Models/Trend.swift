//
//  Trend.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/19.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Trend {
    let amount: Double
    let close: Double
    let market: String
    let start: UInt
    let end: UInt
    let intervals: String
    let open: Double
    let low: Double
    let createTime: UInt
    let high: Double
    let vol: Double

	init(json: JSON) {
		self.amount = json["amount"].doubleValue
		self.close = json["close"].doubleValue
		self.market = json["market"].stringValue
		self.intervals = json["intervals"].stringValue
		self.open = json["open"].doubleValue
		self.low = json["low"].doubleValue
        self.high = json["high"].doubleValue
        self.vol = json["vol"].doubleValue
        self.start = json["start"].uIntValue
        self.end = json["end"].uIntValue
        self.createTime = json["createTime"].uIntValue
	}
}
