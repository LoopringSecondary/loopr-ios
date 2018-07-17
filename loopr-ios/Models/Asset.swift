//
//  Asset.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import BigInt

class Asset: CustomStringConvertible, Equatable {

    let symbol: String
    var name: String
    var icon: UIImage?
    var enable: Bool
    var balance: Double
    var display: String
    var allowance: Double
    var total: Double  // total and currency are for the same value.
    var currency: String
    var description: String
    
    init(json: JSON) {
        self.enable = true
        self.balance = 0.0
        self.allowance = 0.0
        self.display = "0.0"
        self.total = 0.0
        self.currency = Double(0).currency
        self.symbol = json["symbol"].string ?? ""
        self.name = TokenDataManager.shared.getTokenBySymbol(symbol)?.source ?? ""
        self.icon = UIImage(named: "Token-\(self.symbol)-\(Themes.getTheme())") ?? nil
        self.description = self.name
        if let balance = Asset.getAmount(of: symbol, fromWeiAmount: json["balance"].stringValue) {
            self.balance = balance
            let length = Asset.getLength(of: symbol) ?? 4
            self.display = self.balance.withCommas(length)
        }
        if let allowance = Asset.getAmount(of: symbol, fromWeiAmount: json["allowance"].stringValue) {
            self.allowance = allowance
        }
    }
    
    init(symbol: String) {
        self.symbol = symbol
        self.name = ""
        self.enable = true
        self.description = self.name
        self.balance = 0.0
        self.allowance = 0.0
        self.display = "0.0"
        self.total = 0.0
        self.currency = Double(0).currency
        self.icon = UIImage(named: "Token-\(self.symbol)-\(Themes.getTheme())") ?? nil
    }
    
    static func getLength(of symbol: String) -> Int? {
        var result: Int? = nil
        if let price = PriceDataManager.shared.getPrice(of: symbol) {
            result = price.ints + 2
        }
        return result
    }

    static func getAmount(of symbol: String, fromWeiAmount weiAmount: String) -> Double? {
        var index: String.Index
        var result: Double? = nil
        // hex string
        if weiAmount.lowercased().starts(with: "0x") {
            let hexString = weiAmount.dropFirst(2)
            let decString = BigUInt(hexString, radix: 16)!.description
            return getAmount(of: symbol, fromWeiAmount: decString)
        } else if let token = TokenDataManager.shared.getTokenBySymbol(symbol) {
            var amount = weiAmount
            guard token.decimals < 100 || token.decimals >= 0 else {
                return result
            }
            if amount == "0" {
                return 0
            }
            if token.decimals >= amount.count {
                let prepend = String(repeating: "0", count: token.decimals - amount.count + 1)
                amount = prepend + amount
            }
            index = amount.index(amount.endIndex, offsetBy: -token.decimals)
            amount.insert(".", at: index)
            result = Double(amount)
        }
        return result
    }

    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
