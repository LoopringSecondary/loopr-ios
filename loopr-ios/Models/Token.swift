//
//  Token.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class Token {
    
    let token: String
    let balance: String
    let allowance: String
    
    init(json: JSON) {
        self.token = json["token"].stringValue
        self.balance = json["balance"].stringValue
        self.allowance = json["allowance"].stringValue
    }
}
