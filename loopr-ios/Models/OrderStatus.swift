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
        case .opened: return NSLocalizedString("Order Submitted", comment: "")
        case .cutoff: return NSLocalizedString("Order Cancelled", comment: "")
        case .finished: return NSLocalizedString("Order Completed", comment: "")
        case .cancelled: return NSLocalizedString("Order Cancelled", comment: "")
        case .expire: return NSLocalizedString("Order Expired", comment: "")
        case .locked: return NSLocalizedString("Order Locked", comment: "")
        case .unknown: return NSLocalizedString("Order Unknown", comment: "")
        }
    }
}
