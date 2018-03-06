//
//  Trade.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum TradeType {
    case buy
    case sell
}

class Trade {
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
}
