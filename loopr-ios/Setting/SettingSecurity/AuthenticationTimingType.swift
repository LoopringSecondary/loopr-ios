//
//  AuthenticationTimingType.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/23/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum AuthenticationTimingType: CustomStringConvertible {

    case disable
    case immediately
    case oneMin
    case fiveMins
    case fifteenMins
    case oneHour
    case fourHours
    
    var description: String {
        switch self {
        case .disable: return "Disable"
        case .immediately: return "Immediately"
        case .oneMin: return "After 1 minute"
        case .fiveMins: return "After 5 minutes"
        case .fifteenMins: return "After 15 minutes"
        case .oneHour: return "After 1 hour"
        case .fourHours: return "After 4 hours"
        }
    }
}
