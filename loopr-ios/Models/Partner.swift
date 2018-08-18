//
//  Partner.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/18.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class Partner {
    
    var walletAddress: String
    var partner: String
    
    init(json: JSON) {
        self.walletAddress = json["walletAddress"].stringValue
        self.partner = json["cityPartner"].stringValue
    }
}
