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

    case showSmallAssets = "UserDefaultsKeys.showSmallAssets"
    case showOtherPairs = "UserDefaultsKeys.showOtherPairs"
    
    // Trade. Used in TradeDataManager
    case tradeTokenS = "UserDefaultsKeys.tradeTokenS"
    case tradeTokenB = "UserDefaultsKeys.tradeTokenB"

    // Wallet
    case currentAppWallet = "UserDefaultsKeys.currentAppWallet"
    case appWallets = "UserDefaultsKeys.appWallets"
    case showTradingFeature = "UserDefaultsKeys.showTradingFeature"
    case userContacts = "UserDefaultsKeys.userContacts"
    
    // ThirdParty
    case thirdParty = "UserDefaultsKeys.thirdParty"
    case openID = "UserDefaultsKeys.openid"
    
    // Market
    case cancelledAll = "UserDefaultsKeys.cancelledAll"
    case cancellingOrders = "UserDefaultsKeys.cancellingOrders"
    
    // Setting
    case useLrcFeeRatioUserDefineValue = "UserDefaultsKeys.useLrcFeeRatioUserDefineValue"
    case lrcFeeRatio = "UserDefaultsKeys.lrcFeeRatio"
    
    case orderIntervalTime = "UserDefaultsKeys.orderIntervalTime"

    case passcodeOn = "UserDefaultsKeys.passcodeOn"
    
    // Device token used in push notifications
    case deviceToken = "UserDefaultsKeys.deviceToken"
    
    case largestSkipBuildVersion = "UserDefaultsKeys.largestSkipBuildVersion"

    // MARK: - Deprecated
    // Keep these in the code to avoid using them again in the future.
    // case currentFont = "UserDefaultsKeys.currentcurrentFont"
    // case useMarginSplitUserDefineValue = "UserDefaultsKeys.useMarginSplitUserDefineValue"
    // case marginSplit = "UserDefaultsKeys.marginSplit"
}
