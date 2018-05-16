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
    var display: String
    var createTime: String
    var updateTime: String
    
    init?(json: JSON) {
        self.display = "0.0"
        if let symbol = json["symbol"].string, let value = json["value"].string, let from = json["from"].string, let to = json["to"].string, let owner = json["owner"].string, let txHash = json["txHash"].string {
            self.symbol = symbol
            self.value = value
            if let value = Asset.getAmount(of: symbol, fromWeiAmount: value) {
                self.value = value.format().description
                if let price = PriceDataManager.shared.getPriceBySymbol(of: symbol) {
                    let total = price * Double(value)
                    self.display = total.currency
                }
            } else {
                return nil
            }
            
            self.to = to
            self.from = from
            self.owner = owner
            self.txHash = txHash
        } else {
            return nil
        }

        self.type = TxType(rawValue: json["type"].string ?? "unsupported_contract") ?? .unsupportedContract
        self.status = TxStatus(rawValue: json["status"].string ?? "other") ?? .other
        self.icon = UIImage(named: self.type.description) ?? nil
        let createTime = DateUtil.convertToDate(json["createTime"].uIntValue, format: "HH:mm EEE, MMM dd, yyyy")
        self.createTime = createTime
        let updateTime = DateUtil.convertToDate(json["updateTime"].uIntValue, format: "HH:mm EEE, MMM dd, yyyy")
        self.updateTime = updateTime
    }

    enum TxType: String, CustomStringConvertible {
        case approved = "approve"
        case sent = "send"
        case received = "receive"
        case sold = "sell"
        case bought = "buy"
        case convert_income = "convert_income"
        case convert_outcome = "convert_outcome"
        case canceledOrder = "cancel_order"
        case cutoff = "cutoff"
        case unsupportedContract = "unsupported_contract"
        
        var description: String {
            switch self {
            case .approved: return "Enable"
            case .sent: return "Sent"
            case .received: return "Received"
            case .sold: return "Trading"
            case .bought: return "Trading"
            case .convert_income: return "Convert" // eth <-> weth
            case .convert_outcome: return "Convert" // eth <-> weth
            case .canceledOrder: return "Cancel"
            case .cutoff: return "Cancel"
            case .unsupportedContract: return "Other"
            }
        }
    }
    
    enum TxStatus: String, CustomStringConvertible {
        case pending
        case success
        case failed
        case other
        
        var description: String {
            switch self {
            case .pending: return "Pending"
            case .success: return "Complete"
            case .failed: return "Failed"
            case .other: return "Other"
            }
        }
    }
}
