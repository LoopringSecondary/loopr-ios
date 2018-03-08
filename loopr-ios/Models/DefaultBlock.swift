//
//  DefaultBlock.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/7.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

protocol DefaultBlock {
    func description() -> String
}

enum BlockTag: DefaultBlock {
    
    case latest
    case earliest
    case pending
    
    func description() -> String {
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

class BlockNumber: DefaultBlock {
    
    let number: UInt
    
    init(number: UInt) {
        self.number = number
    }
    
    func description() -> String {
        return String(self.number)
    }
}
