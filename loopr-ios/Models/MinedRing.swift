//
//  MinedRing.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class MinedRing {
    
    let id: UInt
    let ringhash: String
    let tradeAmount: UInt
    let miner: String
    let feeRecepient: String
    let txHash: String
    let blockNumber: UInt
    let totalLrcFee: String
    let protocol_value: String
    let isRinghashReserved: Bool
    let ringIndex: String
    let timestamp: UInt
    
    init(json: JSON) {
        self.id = json["id"].uIntValue
        self.ringhash = json["ringhash"].stringValue
        self.tradeAmount = json["tradeAmount"].uIntValue
        self.miner = json["miner"].stringValue
        self.feeRecepient = json["feeRecepient"].stringValue
        self.txHash = json["txHash"].stringValue
        self.blockNumber = json["blockNumber"].uIntValue
        self.totalLrcFee = json["totalLrcFee"].stringValue
        self.protocol_value = json["protocol_value"].stringValue
        self.isRinghashReserved = json["isRinghashReserved"].boolValue
        self.ringIndex = json["ringIndex"].stringValue
        self.timestamp = json["timestamp"].uIntValue
    }
}
