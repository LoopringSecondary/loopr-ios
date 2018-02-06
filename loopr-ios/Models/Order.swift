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
    let dealtAmountB: String
    let dealtAmountS: String
    
    init(originalOrder: OriginalOrder, orderStatus: OrderStatus, dealtAmountB: String, dealtAmountS: String) {
        self.originalOrder = originalOrder
        self.orderStatus = orderStatus
        self.dealtAmountB = dealtAmountB
        self.dealtAmountS = dealtAmountS
    }
    
}
