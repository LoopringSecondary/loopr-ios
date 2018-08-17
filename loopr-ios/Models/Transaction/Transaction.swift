//
//  Transaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/15.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import UIKit

class Transaction {

    var from: String
    var to: String
    var type: TxType
    var status: TxStatus
    var icon: UIImage?
    var symbol: String
    var value: String
    var owner: String
    var txHash: String
    var currency: String
    var createTime: String
    var updateTime: String
    var gasUsed: Double
    var gasPriceInGWei: Double
    
    init?(json: JSON) {
        self.currency = "0.0"
        if let symbol = json["symbol"].string, let value = json["value"].string, let from = json["from"].string, let to = json["to"].string, let owner = json["owner"].string, let txHash = json["txHash"].string, let gasUsed = json["gas_used"].string, let gasPrice = json["gas_price"].string {
            self.symbol = symbol
            self.value = value
            if let value = Asset.getAmount(of: symbol, fromWeiAmount: value) {
                let length = Asset.getLength(of: symbol) ?? 4
                self.value = value.withCommas(length)
                if let price = PriceDataManager.shared.getPrice(of: symbol) {
                    let total = price * Double(value)
                    self.currency = total.currency
                }
            } else {
                return nil
            }
            self.to = to
            self.from = from
            self.owner = owner
            self.txHash = txHash
            self.gasUsed = Double(gasUsed)!
            self.gasPriceInGWei = Double(gasPrice)! / 1000000000
        } else {
            return nil
        }

        self.type = TxType(rawValue: json["type"].string ?? "other") ?? .other
        self.status = TxStatus(rawValue: json["status"].string ?? "other") ?? .other
        self.icon = UIImage(named: "Transaction-\(self.type.rawValue)-\(Themes.getTheme())") ?? nil
        let createTime = DateUtil.convertToDate(json["createTime"].uIntValue, format: "yyyy-MM-dd HH:mm")
        self.createTime = createTime
        let updateTime = DateUtil.convertToDate(json["updateTime"].uIntValue, format: "yyyy-MM-dd HH:mm")
        self.updateTime = updateTime
    }

}
