//
//  Transaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class ETH_Transaction: Initable {

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

    /*
     
     {
     "Content" : "",
     "LogIndex" : 0,
     "UpdateTime" : 1520229046,
     "Owner" : "0x750aD4351bB728ceC7d639A9511F9D6488f1E259",
     "Value" : "500000000000000000000",
     "BlockNumber" : 302635,
     "ID" : 79,
     "Status" : 2,
     "From" : "0x750aD4351bB728ceC7d639A9511F9D6488f1E259",
     "Protocol" : "0xC01172a87f6cC20E1E3b9aD13a9E715Fbc2D5AA9",
     "Symbol" : "",
     "CreateTime" : 1520229046,
     "Type" : 4,
     "TxHash" : "0x65833a56937dfbc52ad558cbc7032b9573c02840e3a4f75be798afc7a2f687b9",
     "To" : "0xb7e0DAE0A3e4e146BCaf0Fe782bE5AFB14041A10"
     },
     */

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
