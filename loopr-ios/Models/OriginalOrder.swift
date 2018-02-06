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
    let owner: String
    let tokenS: String
    let tokenB: String
    let timestamp: UInt
    let ttl: String
    let salt: String
    let lrcFee: String
    let buyNoMoreThanAmountB: Bool
    let marginSplitPercentage: Double
    let v: String
    let r: String
    let s: String
 
    init(json: JSON) {
        self.protocol_value = json["protocol"].stringValue
        self.owner = json["owner"].stringValue
        self.tokenS = json["tokenS"].stringValue
        self.tokenB = json["tokenB"].stringValue
        self.timestamp = json["timestamp"].uIntValue
        self.ttl = json["ttl"].stringValue
        self.salt = json["salt"].stringValue
        self.lrcFee = json["lrcFee"].stringValue
        self.buyNoMoreThanAmountB = json["buyNoMoreThanAmountB"].boolValue
        self.marginSplitPercentage = json["marginSplitPercentage"].doubleValue
        self.v = json["v"].stringValue
        self.r = json["r"].stringValue
        self.s = json["s"].stringValue
    }
}

