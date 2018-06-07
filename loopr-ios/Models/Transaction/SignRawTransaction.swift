//
//  SignRawTransaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class SignRawTransaction {
    
    var token: String
    var index: Int
    var rawTx: RawTransaction
    var address: String
    
    init(json: JSON) {
        self.token = json["token"].stringValue
        self.index = json["index"].intValue
        self.address = json["address"].stringValue
        self.rawTx = RawTransaction(json: json["data"])
    }
}
