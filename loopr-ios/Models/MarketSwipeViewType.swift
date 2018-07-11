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
        case .favorite: return LocalizedString("Favorite", comment: "")
        case .LRC: return "LRC"
        case .ETH: return "WETH"
        case .all: return LocalizedString("All", comment: "")
        }
    }

}
