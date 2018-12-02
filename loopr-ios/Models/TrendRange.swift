//
//  TrendRange.swift
//  loopr-ios
//
//  Created by xiaoruby on 12/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum TrendRange: CustomStringConvertible {
    
    case oneDay
    case oneWeek
    case oneMonth
    case threeMonths
    case oneYear
    case twoYears
    case all
    
    var description: String {
        switch self {
        case .oneDay: return LocalizedString("1H", comment: "")
        case .oneWeek: return LocalizedString("1W", comment: "")
        case .oneMonth: return LocalizedString("1M", comment: "")
        case .threeMonths: return LocalizedString("3M", comment: "")
        case .oneYear: return LocalizedString("1Y", comment: "")
        case .twoYears: return LocalizedString("2Y", comment: "")
        case .all: return LocalizedString("All", comment: "")
        }
    }
    
    func getTrendInterval() -> TrendInterval {
        switch self {
        case .oneDay:
            return TrendInterval.oneHour
        case .oneWeek:
            return TrendInterval.fourHours
        case .oneMonth:
            return TrendInterval.oneDay
        case .threeMonths:
            return TrendInterval.oneDay
        case .oneYear:
            return TrendInterval.oneWeek
        case .twoYears:
            return TrendInterval.oneWeek
        case .all:
            return TrendInterval.oneWeek
        }
    }
    
    func getCount() -> Int {
        switch self {
        case .oneDay:
            return 24
        case .oneWeek:
            return 42
        case .oneMonth:
            return 30
        case .threeMonths:
            return 90
        case .oneYear:
            return 52
        case .twoYears:
            return 100
        case .all:
            return 100
        }
    }
    
}
