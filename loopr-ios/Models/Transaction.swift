//
//  Transaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Transaction: Initable {

    let blockNumber: String
    let value: String
    let v: String
    let input: String
    let hash: String
    let to: String
    let transactionIndex: String
    let gasPrice: String
    let r: String
    let nonce: String
    let blockHash: String
    let from: String
    let s: String
    let gas: String

    required init(_ json: JSON) {

        self.blockNumber = json["blockNumber"].stringValue
        self.value = json["value"].stringValue
        self.v = json["v"].stringValue
        self.input = json["input"].stringValue
        self.hash = json["hash"].stringValue
        self.to = json["to"].stringValue
        self.transactionIndex = json["transactionIndex"].stringValue
        self.gasPrice = json["gasPrice"].stringValue
        self.r = json["r"].stringValue
        self.nonce = json["nonce"].stringValue
        self.blockHash = json["blockHash"].stringValue
        self.from = json["from"].stringValue
        self.s = json["s"].stringValue
        self.gas = json["gas"].stringValue
    }
}
