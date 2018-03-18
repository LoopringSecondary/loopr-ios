//
//  UserDefaultsKeys.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

enum UserDefaultsKeys: String {
    case hasBeenSetup = "UserDefaultsKeys.hasBeenSetup"
    case favoriteMarkets = "UserDefaultsKeys.favoriteMarkets"
    case lastedThemeIndex = "UserDefaultsKeys.lastedThemeIndex"
    case currentLanguage = "UserDefaultsKeys.currentLanguage"
    case currentFont = "UserDefaultsKeys.currentcurrentFont"
    case hideSmallAssets = "UserDefaultsKeys.hideSmallAssets"
    
    // Trade. Used in TradeDataManager
    case tradeTokenS = "UserDefaultsKeys.tradeTokenS"
    case tradeTokenB = "UserDefaultsKeys.tradeTokenB"

    // Wallet
    case currentAppWallet = "UserDefaultsKeys.currentAppWallet"
    case appWallets = "UserDefaultsKeys.appWallets"
}
