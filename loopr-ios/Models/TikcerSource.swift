//
//  TikcerSource.swift
//  loopr-ios
//
//  Created by kenshin on 2018/9/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum TikcerSource: Int, CustomStringConvertible {
    
    case loopring = 1
    case coinmarketcap
    
    var description: String {
        switch self {
        case .loopring: return "loopring"
        case .coinmarketcap: return "coinmarketcap"
        }
    }
}
