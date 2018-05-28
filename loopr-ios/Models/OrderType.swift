//
//  OrderType.swift
//  loopr-ios
//
//  Created by kenshin on 2018/5/28.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum OrderType: String, CustomStringConvertible {
    
    case marketOrder = "market_order"
    case p2pOrder = "p2p_order"
    case unknown = "unknown_order"
    
    var description: String {
        switch self {
        case .marketOrder: return "Market Order"
        case .p2pOrder: return "P2P Order"
        case .unknown: return "Unknown"
        }
    }
}
