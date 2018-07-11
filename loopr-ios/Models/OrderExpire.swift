//
//  OrderExpire.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum OrderExpire: CustomStringConvertible {
    
    case oneHour
    case oneDay
    case oneWeek
    case oneMonth
    
    var description: String {
        switch self {
        case .oneHour: return LocalizedString("1 Hour", comment: "")
        case .oneDay: return LocalizedString("1 Day", comment: "")
        case .oneWeek: return LocalizedString("1 Week", comment: "")
        case .oneMonth: return LocalizedString("1 Month", comment: "")
        }
    }
}
