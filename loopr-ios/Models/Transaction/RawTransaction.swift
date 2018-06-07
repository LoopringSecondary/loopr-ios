//
//  RawTransaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/4.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import Geth

class RawTransaction {
    var data: String
    var to: String
    var value: String
    var gasLimit: String
    var gasPrice: String
    var nonce: String
    var chainId: Int
    
    init(data: Data, to: GethAddress, value: GethBigInt, gasLimit: GethBigInt, gasPrice: GethBigInt, nonce: Int64, chainId: Int = 1) {
        self.data = data.hexString
        self.to = to.getHex()
        self.value = value.hexString
        self.gasLimit = gasLimit.hexString
        self.gasPrice = gasPrice.hexString
        self.nonce = nonce.hex
        self.chainId = chainId
    }
    
    init(json: JSON) {
        self.data = json["data"].stringValue
        self.to = json["to"].stringValue
        self.value = json["value"].stringValue
        self.gasLimit = json["gasLimit"].stringValue
        self.gasPrice = json["gasPrice"].stringValue
        self.nonce = json["nonce"].stringValue
        self.chainId = json["chainId"].intValue
    }
}
