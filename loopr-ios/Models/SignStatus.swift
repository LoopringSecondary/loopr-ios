//
//  SignStatus.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum SignStatus: CustomStringConvertible {
    
    case accept
    case reject
    case received
    case txFailed
    
    var description: String {
        switch self {
        case .accept:
            return "accept"
        case .reject:
            return "reject"
        case .received:
            return "received"
        case .txFailed:
            return "txFailed"
        }
    }
}
