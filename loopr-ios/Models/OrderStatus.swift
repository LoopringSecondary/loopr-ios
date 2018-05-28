//
//  OrderStatus.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

enum OrderStatus: String, CustomStringConvertible {

    // TODO: What is the status for an open order?
    case opened = "ORDER_OPENED"
    case finished = "ORDER_FINISHED"
    case cutoff = "ORDER_CUTOFF"
    case cancelled = "ORDER_CANCELLED"
    case expire = "ORDER_EXPIRE"
    case locked = "ORDER_P2P_LOCKED"
    case unknown = "ORDER_UNKNOWN"

    var description: String {
        switch self {
        case .opened: return "Submitted"
        case .cutoff: return "Cancelled"
        case .finished: return "Completed"
        case .cancelled: return "Cancelled"
        case .expire: return "Expired"
        case .locked: return "Locked"
        case .unknown: return "Unknown"
        }
    }
}
