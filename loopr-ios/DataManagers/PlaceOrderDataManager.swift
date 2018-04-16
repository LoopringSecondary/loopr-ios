//
//  PlaceOrderDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class PlaceOrderDataManager {
    
    static let shared = PlaceOrderDataManager()
    
    // Similar naming in Trade.swift
    var tokenA: String = ""
    var tokenB: String = ""
    
    private init() {
        
    }
    
    // TOOD: not sure whether we need this function
    func getPairDescription() -> String {
        return "\(tokenA)" + " / " + "\(tokenB)"
    }

    func new(tokenA: String, tokenB: String) {
        self.tokenA = tokenA
        self.tokenB = tokenB
    }

    func verify(order: OriginalOrder) -> Bool {
        return true
    }

    func complete() -> Bool {
        return true
    }

}
