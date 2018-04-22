//
//  DoubleExtension.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/22.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

extension Double {
    var currency: String {
        let currencyFormatter = NumberFormatter()
        let locale = SettingDataManager.shared.getCurrentCurrency().locale
        currencyFormatter.locale = Locale(identifier: locale)
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: NSNumber(value: self))!
    }
}
