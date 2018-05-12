//
//  OrderBook.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// It's to aggregate the same price of orders
class OrderBook {
    
    var orders: [Order] = []
    var amountBuy: Double
    var amountSell: Double
    let price: Double
    let orderStatus: OrderStatus
    let side: String
    
    init(order: Order) {
        orders.append(order)
        amountBuy = order.originalOrder.amountBuy
        amountSell = order.originalOrder.amountSell
        price = order.price
        orderStatus = order.orderStatus
        side = order.originalOrder.side
    }
    
    func aggregateSamePriceOrder(newOrder: Order) {
        if newOrder.price == self.price && newOrder.orderStatus == self.orderStatus && newOrder.originalOrder.side == self.side {
            orders.append(newOrder)
            self.amountBuy += newOrder.originalOrder.amountBuy
            self.amountSell += newOrder.originalOrder.amountSell
        }
    }
}
