//
//  OrderHistoryType.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/3.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum OrderHistorySwipeType: String, CustomStringConvertible {
    
    case open = "Open"
    case finished = "Finished"
    case cancelled = "Cancelled"
    case expried = "Expired"
    
    var description: String {
        switch self {
        case .open: return LocalizedString("Open", comment: "")
        case .finished: return LocalizedString("Finished", comment: "")
        case .cancelled: return LocalizedString("Cancelled", comment: "")
        case .expried: return LocalizedString("Expired", comment: "")
        }
    }
}
