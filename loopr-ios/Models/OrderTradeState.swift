//
//  OrderTradeState.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// We use finite state machine to organize several steps to order a trade
// Reference: https://en.wikipedia.org/wiki/Finite-state_machine
enum OrderTradeState: String, CustomStringConvertible {

    case empty = "EMPTY"
    case converting = "CONVERTING"
    case reviewing = "REVIEWING"
    case ordered = "ORDERED"
    
    var description: String {
        switch self {
        case .empty: return "Empty"
        case .converting: return "Converting"
        case .reviewing: return "Reviewing"
        case .ordered: return "Ordered"
        }
    }

}
