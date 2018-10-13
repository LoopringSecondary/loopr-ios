//
//  P2POrderHistoryDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// TODO: consider share code with OrderDataManager.
// It's to all P2P orders of an address.
class P2POrderHistoryDataManager {
    
    static let shared = P2POrderHistoryDataManager()
    
    private var orders: [Order]
    
    // changed to true when a P2P order is submitted.
    var shouldReloadData: Bool = false
    
    private init() {
        orders = []
    }
    
    func getOrderDataFromLocal(originalOrder: OriginalOrder) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: originalOrder.hash) ?? nil
    }
    
    func getOrders(orderStatuses: [OrderStatus]? = nil) -> [Order] {
        guard let orderStatuses = orderStatuses else {
            return orders
        }
        let filteredOrder = orders.filter { (order) -> Bool in
            orderStatuses.contains(order.orderStatus)
        }
        return filteredOrder
    }

    func getOrders(token: String? = nil) -> [Order] {
        guard let token = token else {
            return orders
        }
        return orders.filter { (order) -> Bool in
            let pair = order.originalOrder.market.components(separatedBy: "-")
            return pair[0].lowercased() == token.lowercased()
        }
    }

    func getOrdersFromServer(pageIndex: UInt, pageSize: UInt = 50, completionHandler: @escaping (_ orders: [Order], _ error: Error?) -> Void) {
        if let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getOrders(owner: owner, orderType: OrderType.p2pOrder.rawValue, pageIndex: pageIndex, pageSize: pageSize) { orders, error in
                guard let orders = orders, error == nil else {
                    self.orders = []
                    completionHandler([], error)
                    return
                }

                if pageIndex == 1 {
                    self.orders = orders
                } else {
                    self.orders += orders
                }
                completionHandler(orders, error)
            }
        }
    }
}
