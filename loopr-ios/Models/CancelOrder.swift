//
//  CancelOrder.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/13.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class CancelOrder {
    
    var timestamp: Int64!
    var type: CancelType!
    var orderHash: String!
    var tokenS: String!
    var tokenB: String!
    var owner: String!
    var cutoff: Int64!
    var hash: String!
    
    init(json: JSON) {
        self.timestamp = json["timestamp"].int64Value
        self.type = CancelType(rawValue: json["type"].intValue)
        self.orderHash = json["orderHash"].stringValue
        self.tokenS = json["tokenS"].stringValue
        self.tokenB = json["tokenB"].stringValue
        self.owner = json["owner"].stringValue
        self.cutoff = json["cutoff"].int64Value
        self.hash = json["hash"].stringValue
    }
    
    func isValid() -> Bool {
        let result: Bool = true
        guard self.owner != nil && timestamp != nil else { return false }
        if self.type == CancelType.hash {
            guard self.orderHash != nil else { return false }
        } else if self.type == CancelType.time {
            guard self.cutoff != nil else { return false }
        } else if self.type == CancelType.market {
            guard self.tokenS != nil && self.tokenB != nil else { return false }
        }
        return result
    }
}
