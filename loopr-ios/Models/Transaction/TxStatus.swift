//
//  TxStatus.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension Transaction {
    enum TxStatus: String, CustomStringConvertible {
        case pending
        case success
        case failed
        case other
        
        var description: String {
            switch self {
            case .pending: return LocalizedString("Pending", comment: "")
            case .success: return LocalizedString("Completed", comment: "")
            case .failed: return LocalizedString("Failed", comment: "")
            case .other: return LocalizedString("Other", comment: "")
            }
        }
    }
}
