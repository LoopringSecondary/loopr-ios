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
    case lrcSequence = "UserDefaultsKeys.lrcSequence"
    case wethSequence = "UserDefaultsKeys.wethSequence"
    case favoriteSequence = "UserDefaultsKeys.favoriteSequence"
    case allSequence = "UserDefaultsKeys.allSequence"
    case lastedThemeIndex = "UserDefaultsKeys.lastedThemeIndex"
    case currentLanguage = "UserDefaultsKeys.currentLanguage"
    case currentCurrency = "UserDefaultsKeys.currentCurrency"
    case currentFont = "UserDefaultsKeys.currentcurrentFont"
    case showSmallAssets = "UserDefaultsKeys.showSmallAssets"
    case orderHistory = "UserDefaultsKeys.orderHistory"
    
    // Trade. Used in TradeDataManager
    case tradeTokenS = "UserDefaultsKeys.tradeTokenS"
    case tradeTokenB = "UserDefaultsKeys.tradeTokenB"

    // Wallet
    case currentAppWallet = "UserDefaultsKeys.currentAppWallet"
    case appWallets = "UserDefaultsKeys.appWallets"
    
    //Settings Bundle
    case app_version = "UserDefaultsKeys.app_version"
    case app_build_number = "UserDefaultsKeys.app_build_number"
}
