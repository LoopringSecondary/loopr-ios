//
//  Order.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class Order {
    
    let originalOrder: OriginalOrder
    let orderStatus: OrderStatus
    let dealtAmountB: Double
    let dealtAmountS: Double
    let tradingPairDescription: String
    
    init(originalOrder: OriginalOrder, orderStatus: OrderStatus, dealtAmountB: String, dealtAmountS: String) {
        self.originalOrder = originalOrder
        self.orderStatus = orderStatus
        self.dealtAmountB = Asset.getAmount(of: originalOrder.tokenB, from: dealtAmountB) ?? 0.0
        self.dealtAmountS = Asset.getAmount(of: originalOrder.tokenS, from: dealtAmountS) ?? 0.0
        
        if originalOrder.tokenB == "WETH" {
            tradingPairDescription = "\(originalOrder.tokenS)/\(originalOrder.tokenB)"
        } else {
            tradingPairDescription = "\(originalOrder.tokenB)/\(originalOrder.tokenS)"
        }
    }
}
