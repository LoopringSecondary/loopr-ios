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
    case favoriteSequence = "UserDefaultsKeys.favoriteSequence"
    case lastedThemeIndex = "UserDefaultsKeys.lastedThemeIndex"
    case currentLanguage = "UserDefaultsKeys.currentLanguage"
    case currentCurrency = "UserDefaultsKeys.currentCurrency"
    // Deprecated. Keep these in the code to avoid using them again in the future.
    // case currentFont = "UserDefaultsKeys.currentcurrentFont"
    case showSmallAssets = "UserDefaultsKeys.showSmallAssets"
    case showOtherPairs = "UserDefaultsKeys.showOtherPairs"
    
    // Trade. Used in TradeDataManager
    case tradeTokenS = "UserDefaultsKeys.tradeTokenS"
    case tradeTokenB = "UserDefaultsKeys.tradeTokenB"

    // Wallet
    case currentAppWallet = "UserDefaultsKeys.currentAppWallet"
    case appWallets = "UserDefaultsKeys.appWallets"
    
    // Market
    case cancelledAll = "UserDefaultsKeys.cancelledAll"
    case cancellingOrders = "UserDefaultsKeys.cancellingOrders"

    // Setting
    case useLrcFeeRatioUserDefineValue = "UserDefaultsKeys.useLrcFeeRatioUserDefineValue"
    case lrcFeeRatio = "UserDefaultsKeys.lrcFeeRatio"
    
    case orderIntervalTime = "UserDefaultsKeys.orderIntervalTime"
    
    // Deprecated. Keep these in the code to avoid using them again in the future.
    // case useMarginSplitUserDefineValue = "UserDefaultsKeys.useMarginSplitUserDefineValue"
    // case marginSplit = "UserDefaultsKeys.marginSplit"

    case passcodeOn = "UserDefaultsKeys.passcodeOn"
    
    // Device token used in push notifications
    case deviceToken = "UserDefaultsKeys.deviceToken"
    
    case largestSkipBuildVersion = "UserDefaultsKeys.largestSkipBuildVersion"
}
