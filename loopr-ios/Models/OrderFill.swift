//
//  Trade.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrderFill {

    let market: String
    let lrcFee: Double
    let preOrderHash: String
    let side: String
    let ringHash: String
    let splitB: String
    let amount: UInt
    let splitS: String
    let price: Double
    let createTime: UInt
    let orderHash: String
    
    init(market: String, json: JSON) {
        self.market = market
        self.lrcFee = Asset.getAmount(of: "LRC", fromWeiAmount: json["lrcFee"].stringValue) ?? 0.0
        self.preOrderHash = json["preOrderHash"].stringValue
        self.side = json["side"].stringValue
        self.ringHash = json["ringHash"].stringValue
        self.splitB = json["splitB"].stringValue
        self.amount = json["amount"].uIntValue
        self.splitS = json["splitS"].stringValue
        self.price = json["price"].doubleValue
        self.createTime = json["createTime"].uIntValue
        self.orderHash = json["orderHash"].stringValue
    }

}
