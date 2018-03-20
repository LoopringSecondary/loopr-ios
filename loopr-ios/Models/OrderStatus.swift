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
    case cancel = "ORDER_CANCEL"

    var description: String {
        switch self {
        case .opened: return "Opened"
        case .cutoff: return "Cutoff"
        case .finished: return "Finished"
        case .cancel: return "Cancel"
        }
    }
}
