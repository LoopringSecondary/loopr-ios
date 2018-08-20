//
//  P2PType.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/20.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum P2PType: String, CustomStringConvertible {
    
    case maker = "maker"
    case taker = "taker"
    case unknown = "unknown_type"
    
    var description: String {
        switch self {
        case .maker: return "Maker"
        case .taker: return "Taker"
        case .unknown: return "Unknown"
        }
    }
}
