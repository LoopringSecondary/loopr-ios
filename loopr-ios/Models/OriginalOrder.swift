//
//  OriginalOrder.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class OriginalOrder {

    // protocol is a keyword in Swift
    let protocol_value: String
    let address: String
    let market: String
    let tokenS: String
    let tokenB: String
    let validSince: String
    let validUntil: String
    let amountBuy: Double
    let amountSell: Double
    let lrcFee: Double
    let buyNoMoreThanAmountB: Bool
    let marginSplitPercentage: String
    let v: String
    let r: String
    let s: String
    let manager = AssetDataManager.shared

    init(json: JSON) {
        self.protocol_value = json["protocol"].stringValue
        self.address = json["address"].stringValue
        self.market = json["market"].stringValue
        self.tokenS = json["tokenS"].stringValue
        self.tokenB = json["tokenB"].stringValue
        self.buyNoMoreThanAmountB = json["buyNoMoreThanAmountB"].boolValue
        self.v = json["v"].stringValue
        self.r = json["r"].stringValue
        self.s = json["s"].stringValue
        
        let since = UInt(json["validSince"].stringValue.dropFirst(2), radix: 16)!
        self.validSince = DateUtil.convertToDate(since, format: "yyyy-MM-dd")
        let until = UInt(json["validUntil"].stringValue.dropFirst(2), radix: 16)!
        self.validUntil = DateUtil.convertToDate(until, format: "yyyy-MM-dd")
        let percentage = UInt(json["marginSplitPercentage"].stringValue.dropFirst(2), radix: 16)!
        self.marginSplitPercentage = percentage.description + "%"
        let amountS = json["amountS"].stringValue
        self.amountSell = manager.getAmount(of: self.tokenS, from: amountS)!
        let amountB = json["amountB"].stringValue
        self.amountBuy = manager.getAmount(of: self.tokenB, from: amountB)!
        let fee = json["lrcFee"].stringValue
        self.lrcFee = manager.getAmount(of: "LRC", from: fee)!
    }
}
