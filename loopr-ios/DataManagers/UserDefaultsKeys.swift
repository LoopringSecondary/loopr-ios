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
    case showOtherPairs = "UserDefaultsKeys.showOtherPairs"
    case orderHistory = "UserDefaultsKeys.orderHistory"
    case gasPrice = "UserDefaultsKeys.gasPrice"
    
    // Trade. Used in TradeDataManager
    case tradeTokenS = "UserDefaultsKeys.tradeTokenS"
    case tradeTokenB = "UserDefaultsKeys.tradeTokenB"

    // Wallet
    case currentAppWallet = "UserDefaultsKeys.currentAppWallet"
    case appWallets = "UserDefaultsKeys.appWallets"
    
    // Market
    case cancelledAll = "UserDefaultsKeys.cancelledAll"
    case cancellingOrders = "UserDefaultsKeys.cancellingOrders"
    
    //Settings Bundle
    case appVersion = "UserDefaultsKeys.appVersion"
    case appBuildNumber = "UserDefaultsKeys.appBuildNumber"
    
    // Setting
    case useLrcFeeRatioUserDefineValue = "UserDefaultsKeys.useLrcFeeRatioUserDefineValue"
    case lrcFeeRatio = "UserDefaultsKeys.lrcFeeRatio"
    
    case useMarginSplitUserDefineValue = "UserDefaultsKeys.useMarginSplitUserDefineValue"
    case marginSplit = "UserDefaultsKeys.marginSplit"

    case passcodeOn = "UserDefaultsKeys.passcodeOn"
}
