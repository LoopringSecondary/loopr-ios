//
//  ProductDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/8/27.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum Production: String {
    
    // TODO: We will have blue color configuration.
    case loopr = "Loopr Wallet"
    case upwallet = "UP Wallet"
    case vivwallet = "vivwallet"
    
    // Only need to change this line of code
    static let current: Production = .vivwallet
    
    static func getProduct() -> String {
        return current.rawValue
    }
}
