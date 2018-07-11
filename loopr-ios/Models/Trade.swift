//
//  Trade.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum TradeType: CustomStringConvertible {
    case buy
    case sell
    
    var description: String {
        switch self {
        case .buy: return LocalizedString("Buy", comment: "")
        case .sell: return LocalizedString("Sell", comment: "")
        }
    }
}

class Trade {
    
    let id: String
    let blockNumber: String
    let lrcFee: UInt
    let market: String
    let preOrderHash: String
    let amountB: String
    let ringHash: String
    let splitB: String
    let ringIndex: UInt
    let splitS: String
    let orderHash: String
    let lrcReward: String
    let tokenS: String
    let protocol_value: String
    let amountS: String
    let owner: String
    let tokenB: String
    let nextOrderHash: String
    let fillIndex: UInt
    let txHash: String
    let createTime: UInt
    
    init(json: JSON) {
        self.id = json["id"].stringValue 
        self.blockNumber = json["blockNumber"].stringValue 
        self.lrcFee = json["lrcFee"].uIntValue
        self.market = json["market"].stringValue 
        self.preOrderHash = json["preOrderHash"].stringValue 
        self.amountB = json["amountB"].stringValue 
        self.ringHash = json["ringHash"].stringValue 
        self.splitB = json["splitB"].stringValue 
        self.ringIndex = json["ringIndex"].uIntValue
        self.splitS = json["splitS"].stringValue 
        self.orderHash = json["orderHash"].stringValue 
        self.lrcReward = json["lrcReward"].stringValue 
        self.tokenS = json["tokenS"].stringValue 
        self.protocol_value = json["protocol_value"].stringValue 
        self.amountS = json["amountS"].stringValue 
        self.owner = json["owner"].stringValue 
        self.tokenB = json["tokenB"].stringValue 
        self.nextOrderHash = json["nextOrderHash"].stringValue 
        self.fillIndex = json["fillIndex"].uIntValue
        self.txHash = json["txHash"].stringValue 
        self.createTime = json["createTime"].uIntValue
    }
}
