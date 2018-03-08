//
//  DefaultBlock.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

enum BlockTag: CustomStringConvertible {

    case latest
    case earliest
    case pending

    var description: String {
        switch self {
        case .latest:
        return "latest"
        case .earliest:
        return "earliest"
        case .pending:
        return "pending"
        }
    }
}

class BlockNumber: CustomStringConvertible {
    
    let number: UInt
    var description: String
    
    init(number: UInt) {
        self.number = number
        self.description = String(number)
    }

}
