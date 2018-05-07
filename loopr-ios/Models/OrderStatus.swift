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
    case unknown = "ORDER_UNKNOWN"

    var description: String {
        switch self {
        case .opened: return "Opened"
        case .cutoff: return "Cancelled"
        case .finished: return "Finished"
        case .cancelled: return "Cancelled"
        case .expire: return "Expire"
        case .unknown: return "Unknown"
        }
    }
}
