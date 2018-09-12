//
//  TickerTag.swift
//  loopr-ios
//
//  Created by kenshin on 2018/9/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum TickerTag: String, CustomStringConvertible {
    
    case all = "all"
    case whiteList = "whitelist"
    case blackList = "blacklist"
    case defaultList = "defaultlist"
    case unknown = "unknown"
    
    var description: String {
        switch self {
        case .all: return "all"
        case .whiteList: return "whitelist"
        case .blackList: return "blacklist"
        case .defaultList: return "defaultlist"
        case .unknown: return "unknown"
        }
    }
}
