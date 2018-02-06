//
//  OrderDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class OrderDataManager {

    static let shared = OrderDataManager()

    private var orders: [Order]

    private init() {
        orders = []
    }
    
    func getOrders() {
        JSON_RPC.getOrders() { orders, error in
            self.orders = orders
        }
    }
}

