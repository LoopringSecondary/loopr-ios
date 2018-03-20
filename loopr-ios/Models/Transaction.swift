//
//  Transaction.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/15.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    var display: Double
    var createTime: String
    var updateTime: String
    
    init(json: JSON) {
        self.display = 0
        self.from = json["from"].stringValue
        self.to = json["to"].stringValue
        self.type = TxType(rawValue: json["type"].stringValue)!
        self.status = TxStatus(rawValue: json["status"].stringValue)!
        self.icon = UIImage(named: self.type.description) ?? nil
        self.symbol = json["symbol"].stringValue
        self.value = json["value"].stringValue
        self.owner = json["owner"].stringValue
        self.txHash = json["txHash"].stringValue
        self.createTime = Transaction.convertToDate(json["createTime"].uIntValue)
        self.updateTime = Transaction.convertToDate(json["updateTime"].uIntValue)
    }

    enum TxType: String, CustomStringConvertible {
        case approved = "approve"
        case sent = "send"
        case received = "receive"
        case sold = "sell"
        case bought = "buy"
        case converted = "convert"
        case canceledOrder = "cancel_order"
        case cutoff = "cutoff"
        
        var description: String {
            switch self {
            case .approved: return "Approved"
            case .sent: return "Sent"
            case .received: return "Received"
            case .sold: return "Sold"
            case .bought: return "Bought"
            case .converted: return "Converted" // eth <-> weth
            case .canceledOrder: return "Canceled Order"
            case .cutoff: return "Cutoff"
            }
        }
    }
    
    enum TxStatus: String, CustomStringConvertible {
        case pending
        case success
        case failed
        
        var description: String {
            switch self {
            case .pending: return "Pending"
            case .success: return "Complete"
            case .failed: return "Failed"
            }
        }
    }

    class func convertToDate(_ timeStamp: UInt) -> String {
        let timeInterval: TimeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm - MMM dd, yyyy"
        let time = dateformatter.string(from: date)
        return time
    }
}
