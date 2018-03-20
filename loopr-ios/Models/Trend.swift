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
    let start: String
    let end: String
    let intervals: String
    let open: Double
    let low: Double
    let createTime: String
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
        self.start = Transaction.convertToDate(json["start"].uIntValue)
        self.end = Transaction.convertToDate(json["end"].uIntValue)
        self.createTime = Transaction.convertToDate(json["createTime"].uIntValue)
	}
}
