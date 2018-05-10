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

    private var sells: [Order] = []
    private var buys: [Order] = []
    
    private init() {
        
    }

    // TODO: Not sure how orders are sorted in JSON RPC API. So send two requests.
    func getOrderBookFromServer(market: String, completionHandler: @escaping (_ sells: [Order], _ buys: [Order], _ error: Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        LoopringAPIRequest.getOrders(owner: nil, status: OrderStatus.opened.rawValue, market: market, side: "sell") { orders, error in
            guard let orders = orders, error == nil else {
                return
            }
            self.sells = orders
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        LoopringAPIRequest.getOrders(owner: nil, status: OrderStatus.opened.rawValue, market: market, side: "buy") { orders, error in
            guard let orders = orders, error == nil else {
                return
            }
            self.buys = orders
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
            completionHandler(self.sells, self.buys, nil)
        }
    }
}
