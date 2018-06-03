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
            case .sent: return NSLocalizedString("Sent", comment: "")
            case .received: return NSLocalizedString("Received", comment: "")
            case .sold: return NSLocalizedString("Sold", comment: "")
            case .bought: return NSLocalizedString("Bought", comment: "")
            case .convert_income: return NSLocalizedString("Convert", comment: "") // eth <-> weth
            case .convert_outcome: return NSLocalizedString("Convert", comment: "") // eth <-> weth
            case .canceledOrder: return NSLocalizedString("Cancel", comment: "")
            case .cutoff: return NSLocalizedString("Cancel", comment: "")
            case .unsupportedContract: return "Unknown"
            }
        }
    }
}
