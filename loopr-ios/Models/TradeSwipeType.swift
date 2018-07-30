//
//  TxSwipeViewType.swift
//  loopr-ios
//
//  Created by 王忱 on 2018/7/19.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum TradeSwipeType: String, CustomStringConvertible {
    
    case trade = "Trade"
    case records = "Records"
    
    var description: String {
        switch self {
        case .trade: return LocalizedString("Trade", comment: "")
        case .records: return LocalizedString("Records", comment: "")
        }
    }
}
