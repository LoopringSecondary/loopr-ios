//
//  MarketSwipeViewType.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum MarketSwipeViewType: String, CustomStringConvertible {
    
    case favorite = "Favorite"
    case LRC = "LRC"
    case ETH = "WETH"
    case all = "All"
    
    var description: String {
        switch self {
        case .favorite: return NSLocalizedString("Favorite", comment: "")
        case .LRC: return NSLocalizedString("LRC", comment: "")
        case .ETH: return NSLocalizedString("WETH", comment: "")
        case .all: return NSLocalizedString("All", comment: "")
        }
    }

}