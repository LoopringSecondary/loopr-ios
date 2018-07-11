//
//  OrderStatus.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//
import UIKit

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
        case .opened: return LocalizedString("Order Submitted", comment: "")
        case .cutoff: return LocalizedString("Order Cancelled", comment: "")
        case .finished: return LocalizedString("Order Completed", comment: "")
        case .cancelled: return LocalizedString("Order Cancelled", comment: "")
        case .expire: return LocalizedString("Order Expired", comment: "")
        case .locked: return LocalizedString("Order Locked", comment: "")
        case .unknown: return LocalizedString("Order Unknown", comment: "")
        }
    }
}
