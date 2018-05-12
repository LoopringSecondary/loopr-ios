//
//  OrderBookDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// Get a list of orders for a market and group them by price.
// It's not binding to an address.
class OrderBookDataManager {

    static let shared = OrderBookDataManager()

    private var sells: [OrderBook] = []
    private var buys: [OrderBook] = []
    
    private init() {
        
    }
    
    func getSells() -> [OrderBook] {
        return Array(sells.prefix(4)).reversed()
    }
    
    func getBuys() -> [OrderBook] {
        return Array(buys.prefix(4))
    }

    // TODO: Not sure how orders are sorted in JSON RPC API. So send two requests.
    func getOrderBookFromServer(market: String, completionHandler: @escaping (_ sells: [OrderBook], _ buys: [OrderBook], _ error: Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        LoopringAPIRequest.getOrders(owner: nil, status: OrderStatus.opened.rawValue, market: market, side: "sell") { orders, error in
            guard let orders = orders, error == nil else {
                return
            }
            // ascending
            let sortedOrders = orders.sorted(by: { (order1, order2) -> Bool in
                return order1.price < order2.price
            })
            
            // TODO: I agree that the following logic is complicated.
            self.sells = []
            for (index, order) in sortedOrders.enumerated() {
                let orderBook = OrderBook(order: order)
                if index == 0 {
                    self.sells.append(orderBook)
                } else {
                    let lastItem = self.sells.last!
                    if lastItem.price == orderBook.price && lastItem.orderStatus == order.orderStatus && lastItem.side == orderBook.side {
                        lastItem.aggregateSamePriceOrder(newOrder: order)
                        self.sells[self.sells.count-1] = lastItem
                    } else {
                        self.sells.append(orderBook)
                    }
                }
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        LoopringAPIRequest.getOrders(owner: nil, status: OrderStatus.opened.rawValue, market: market, side: "buy") { orders, error in
            guard let orders = orders, error == nil else {
                return
            }
            // descending
            let sortedOrders = orders.sorted(by: { (order1, order2) -> Bool in
                return order1.price > order2.price
            })
            
            // TODO: I agree that the following logic is complicated. 
            self.buys = []
            for (index, order) in sortedOrders.enumerated() {
                let orderBook = OrderBook(order: order)
                if index == 0 {
                    self.buys.append(orderBook)
                } else {
                    let lastItem = self.buys.last!
                    if lastItem.price == orderBook.price && lastItem.orderStatus == order.orderStatus && lastItem.side == orderBook.side {
                        lastItem.aggregateSamePriceOrder(newOrder: order)
                        self.buys[self.buys.count-1] = lastItem
                    } else {
                        self.buys.append(orderBook)
                    }
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
            completionHandler(self.getSells(), self.getBuys(), nil)
        }
    }
}
