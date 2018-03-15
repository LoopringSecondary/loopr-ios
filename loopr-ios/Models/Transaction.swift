//
//  Transaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/15.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Transaction {

    let from: String
    let to: String
    let type: String
    let status: String
    let symbol: String
    let value: Double
    let owner: String
    let txHash: String
    let createTime: String
    let updateTime: String
    
    init(json: JSON) {
        self.from = json["from"].stringValue
        self.to = json["to"].stringValue
        self.type = json["type"].stringValue
        self.status = json["status"].stringValue
        self.symbol = json["symbol"].stringValue
        self.value = json["value"].doubleValue
        self.owner = json["owner"].stringValue
        self.txHash = json["txHash"].stringValue
        self.createTime = json["createTime"].stringValue
        self.updateTime = json["updateTime"].stringValue
    }
    
}
