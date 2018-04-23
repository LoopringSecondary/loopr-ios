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

// TODO: What is difference between Asset and Token? Could we merge these two classes?
class Asset: CustomStringConvertible, Equatable {

    let symbol: String
    var name: String   // TODO: not used?
    var icon: UIImage?
    var enable: Bool
    var rawBalance: String
    var balance: Double
    var allowance: String  // TODO: why allowance is String?
    var display: String
    var description: String
    
    init(json: JSON) {
        self.enable = true
        self.display = "0"

        self.symbol = json["symbol"].stringValue
        self.allowance = json["allowance"].stringValue
        self.icon = UIImage(named: self.symbol) ?? nil

        self.name = TokenDataManager.shared.getTokenBySymbol(symbol)?.source ?? "unknown token"
        self.description = self.name

        self.rawBalance = json["balance"].stringValue
        self.balance = 0.0
        if let balance = Asset.getAmount(of: symbol, from: rawBalance) {
            self.balance = balance
        }
    }
    
    init(symbol: String) {
        self.symbol = symbol
        self.name = ""
        self.enable = true
        self.description = self.name
        
        self.allowance = "0"
        self.icon = UIImage(named: self.symbol) ?? nil

        self.rawBalance = "0"
        self.balance = 0.0
        
        self.display = Double(0).currency
    }
    
    // TODO: Why precision is 4?
    static func getAmount(of symbol: String, from gweiAmount: String, to precision: Int = 4) -> Double? {
        var index: String.Index
        var result: Double? = nil
        // hex string
        if gweiAmount.lowercased().starts(with: "0x") {
            let hexString = gweiAmount.dropFirst(2)
            let decString = BigUInt(hexString, radix: 16)!.description
            return getAmount(of: symbol, from: decString, to: precision)
        } else if let token = TokenDataManager.shared.getTokenBySymbol(symbol) {
            var amount = gweiAmount
            guard token.decimals < 100 || token.decimals >= 0 else {
                return result
            }
            if token.decimals >= amount.count {
                let prepend = String(repeating: "0", count: token.decimals - amount.count + 1)
                amount = prepend + amount
            }

            if amount == "0" {
                return 0
            }

            if precision >= token.decimals {
                index = amount.index(amount.endIndex, offsetBy: -token.decimals)
            } else {
                let offset = precision - token.decimals
                index = amount.index(amount.endIndex, offsetBy: offset)
                amount.removeSubrange(index...)
            }
            amount.insert(".", at: index)
            result = Double(amount)
        }
        return result
    }

    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.symbol == rhs.symbol
    }

}
