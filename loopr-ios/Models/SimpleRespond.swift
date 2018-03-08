//
//  SimpleRespond.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/8.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class SimpleRespond: Initable {
    
    let respond: String
    
    required init(_ json: JSON) {
        self.respond = json.stringValue
    }
}
