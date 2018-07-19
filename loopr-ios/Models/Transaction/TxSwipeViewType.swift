//
//  TxSwipeViewType.swift
//  loopr-ios
//
//  Created by 王忱 on 2018/7/19.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum TxSwipeViewType: String, CustomStringConvertible {
    
    case all = "All"
    case time = "Time"
    case type = "Type"
    case status = "Status"
    
    var description: String {
        switch self {
        case .all: return LocalizedString("all", comment: "")
        case .time: return LocalizedString("time", comment: "")
        case .type: return LocalizedString("type", comment: "")
        case .status: return LocalizedString("status", comment: "")
        }
    }
}
