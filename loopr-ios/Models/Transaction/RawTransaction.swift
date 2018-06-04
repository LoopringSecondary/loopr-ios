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
    var data: Data
    var to: GethAddress
    var value: GethBigInt
    var gasLimit: GethBigInt
    var gasPrice: GethBigInt
    var nonce: Int64
    var chainId: Int
    
    init(data: Data, to: GethAddress, value: GethBigInt, gasLimit: GethBigInt, gasPrice: GethBigInt, nonce: Int64, chainId: Int = 1) {
        self.data = data
        self.to = to
        self.value = value
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce
        self.chainId = chainId
    }
}
