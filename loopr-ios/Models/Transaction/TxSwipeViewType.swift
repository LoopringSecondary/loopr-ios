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
        case .all: return LocalizedString("All", comment: "")
        case .time: return LocalizedString("Time", comment: "")
        case .type: return LocalizedString("Type", comment: "")
        case .status: return LocalizedString("Status", comment: "")
        }
    }
}
