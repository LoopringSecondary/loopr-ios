//
//  OriginalOrder.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OriginalOrder {

    // protocol is a keyword in Swift
    let delegate: String
    let address: String
    let market: String
    let tokenBuy: String
    let tokenSell: String
    let amountBuy: Double
    let amountSell: Double
    let validSince: Int64
    let validUntil: Int64
    let lrcFee: Double
    let buyNoMoreThanAmountB: Bool
    let side: String
    let hash: String
    let v: String
    let r: String
    let s: String
    
    init(delegate: String, address: String, side: String, tokenS: String, tokenB: String, validSince: Int64, validUntil: Int64, amountBuy: Double, amountSell: Double, lrcFee: Double, buyNoMoreThanAmountB: Bool, market: String = "", hash: String = "", v: String = "", r: String = "", s: String = "") {
        self.delegate = delegate
        self.address = address
        self.market = market
        self.tokenSell = tokenS
        self.tokenBuy = tokenB
        self.validSince = validSince
        self.validUntil = validUntil
        self.amountBuy = amountBuy
        self.amountSell = amountSell
        self.lrcFee = lrcFee
        self.buyNoMoreThanAmountB = buyNoMoreThanAmountB
        self.side = side
        self.hash = hash
        self.v = v
        self.r = r
        self.s = s
    }

    init(json: JSON) {
        self.delegate = json["protocol"].stringValue
        self.address = json["address"].stringValue
        self.market = json["market"].stringValue
        self.tokenSell = json["tokenS"].stringValue
        self.tokenBuy = json["tokenB"].stringValue
        self.buyNoMoreThanAmountB = json["buyNoMoreThanAmountB"].boolValue
        self.side = json["side"].stringValue
        self.hash = json["hash"].stringValue
        self.v = json["v"].stringValue
        self.r = json["r"].stringValue
        self.s = json["s"].stringValue
        
        self.validSince = Int64(json["validSince"].stringValue.dropFirst(2), radix: 16)!
        self.validUntil = Int64(json["validUntil"].stringValue.dropFirst(2), radix: 16)!
        let amountS = json["amountS"].stringValue
        self.amountSell = Asset.getAmount(of: self.tokenSell, fromGweiAmount: amountS) ?? 0.0
        let amountB = json["amountB"].stringValue
        self.amountBuy = Asset.getAmount(of: self.tokenBuy, fromGweiAmount: amountB) ?? 0.0
        let fee = json["lrcFee"].stringValue
        self.lrcFee = Asset.getAmount(of: "LRC", fromGweiAmount: fee)!
    }
}
