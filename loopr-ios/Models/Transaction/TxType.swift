//
//  TxType.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension Transaction {
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
}
