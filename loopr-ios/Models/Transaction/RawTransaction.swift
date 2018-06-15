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
    var nonce: Int64 = 0
    var chainId: Int
    
    init(data: Data, to: GethAddress, value: GethBigInt, gasLimit: GethBigInt, gasPrice: GethBigInt, nonce: Int64, chainId: Int = 1) {
        self.data = data.hexString
        self.to = to.getHex()
        self.value = value.hexString
        self.gasLimit = gasLimit.hexString
        self.gasPrice = gasPrice.hexString
        self.nonce = nonce
        self.chainId = chainId
    }
    
    init(json: JSON) {
        self.data = json["data"].stringValue
        self.to = json["to"].stringValue
        self.value = json["value"].stringValue
        self.gasLimit = json["gasLimit"].stringValue
        self.gasPrice = json["gasPrice"].stringValue
        self.chainId = json["chainId"].intValue
        self.nonce = Int64(getInt(json["nonce"].string))
    }
    
    func getInt(_ value: String?) -> Int {
        var result: Int = 0
        if let value = value {
            if value.isHex(), let integer = Int(value.dropFirst(2), radix: 16) {
                result = integer
            }
        }
        return result
    }
}
