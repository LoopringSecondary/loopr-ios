//
//  CityPartner.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class PartnerStatus {

    var walletAddress: String
    var customerCount: Int
    var received: [String: JSON]
    
    init(json: JSON) {
        self.walletAddress = json["walletAddress"].stringValue
        self.customerCount = json["customer_count"].intValue
        self.received = json["received"].dictionaryValue
    }
}
