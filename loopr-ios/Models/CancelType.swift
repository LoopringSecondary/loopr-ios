//
//  CancelType.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/13.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum CancelType: Int, CustomStringConvertible {
    
    case hash = 1
    case owner
    case time
    case market
    
    var description: String {
        switch self {
        case .hash: return "cancel order by hash"
        case .owner: return "cancel order by owner"
        case .time: return "cancel order by time"
        case .market: return "cancel order by market"
        }
    }
}
