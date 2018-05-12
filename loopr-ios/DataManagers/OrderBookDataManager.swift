//
//  OrderBookDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

// Get a list of orders for a market and group them by price.
// It's not binding to an address.
class OrderBookDataManager {

    static let shared = OrderBookDataManager()

    let itemCount = UIDevice.current.iPhoneX ? 5 : 4
    private var sells: [OrderBook] = []
    private var buys: [OrderBook] = []
    
    private init() {
        
    }
    
    func getSells() -> [OrderBook] {
        return Array(sells.prefix(itemCount)).reversed()
    }
    
    func getBuys() -> [OrderBook] {
        return Array(buys.prefix(itemCount))
    }

    // TODO: Not sure how orders are sorted in JSON RPC API. So send two requests.
    func getOrderBookFromServer(market: String, completionHandler: @escaping (_ sells: [OrderBook], _ buys: [OrderBook], _ error: Error?) -> Void) {
        LoopringAPIRequest.getOrders(owner: nil, status: OrderStatus.opened.rawValue, market: market) { orders, error in
            guard let orders = orders, error == nil else {
                return
            }

            let buyOrders = orders.filter({ (order) -> Bool in
                order.originalOrder.side == "buy"
            })
            self.buys = OrderBookDataManager.aggregateOrderToOrderBook(orders: buyOrders, side: "buy")

            let sellOrders = orders.filter({ (order) -> Bool in
                order.originalOrder.side == "sell"
            })
            self.sells = OrderBookDataManager.aggregateOrderToOrderBook(orders: sellOrders, side: "sell")

            completionHandler(self.getSells(), self.getBuys(), nil)
        }
    }
    
    class func aggregateOrderToOrderBook(orders: [Order], side: String) -> [OrderBook] {
        let sortedOrders = orders.sorted(by: { (order1, order2) -> Bool in
            if side == "sell" {
                // ascending for sell
                return order1.price < order2.price
            } else {
                // descending for buy
                return order1.price > order2.price
            }
        })
        
        // TODO: I agree that the following logic is complicated.
        var orderBooks: [OrderBook] = []
        for (index, order) in sortedOrders.enumerated() {
            let orderBook = OrderBook(order: order)
            if index == 0 {
                orderBooks.append(orderBook)
            } else {
                let lastItem = orderBooks.last!
                if lastItem.price.withCommas(minimumFractionDigits: 8) == orderBook.price.withCommas(minimumFractionDigits: 8) && lastItem.orderStatus == order.orderStatus && lastItem.side == orderBook.side {
                    lastItem.aggregateSamePriceOrder(newOrder: order)
                    orderBooks[orderBooks.count-1] = lastItem
                } else {
                    orderBooks.append(orderBook)
                }
            }
        }

        return orderBooks
    }

}
