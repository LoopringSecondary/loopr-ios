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

    static func getCurrent() -> Production {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            print("bundle identifier: \(bundleIdentifier)")
            if bundleIdentifier == "leaf.prod.app" {
                return .upwallet
            } else if bundleIdentifier.contains("viv") {
                return .vivwallet
            }
        }
        return .loopr
    }
    
    static func getProduct() -> String {
        return getCurrent().rawValue
    }
}
