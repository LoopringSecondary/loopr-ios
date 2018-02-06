//
//  OrderStatus.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

enum OrderStatus : String, CustomStringConvertible {

    case new = "ORDER_NEW"
    case partial = "ORDER_PARTIAL"
    case finished = "ORDER_FINISHED"
    case cutoff = "ORDER_CUTOFF"
    case cancel = "ORDER_CANCEL"

    var description: String {
        switch self {
            case .new: return "New"
            case .partial: return "Partial"
            case .cutoff: return "Cutoff"
            case .finished: return "Finished"
            case .cancel: return "Cancel"
        }
    }
    
}
