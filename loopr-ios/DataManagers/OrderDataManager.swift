//
//  OrderDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

// It's to all orders of an address.
class OrderDataManager {

    static let shared = OrderDataManager()

    private var orders: [Order]

    private init() {
        orders = []
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
            return order.originalOrder.market.contains(token)
        }
    }
    
    func getOrders(type: OrderHistorySwipeType = .all) -> [Order] {
        switch type {
        case .all:
            return orders
        case .open:
            return orders.filter({ (order) -> Bool in
                return order.orderStatus == .opened ||
                       order.orderStatus == .waited
            })
        case .finished:
            return orders.filter({ (order) -> Bool in
                return order.orderStatus == .finished
            })
        case .cancelled:
            return orders.filter({ (order) -> Bool in
                return order.orderStatus == .cancelled
            })
        case .expried:
            return orders.filter({ (order) -> Bool in
                return order.orderStatus == .expire
            })
        }
    }

    func shouldCancelAll() -> Bool {
        let defaults = UserDefaults.standard
        var result = defaults.bool(forKey: UserDefaultsKeys.cancelledAll.rawValue)
        guard !result else { return false }
        let openOrders = self.getOrders(orderStatuses: [.opened, .waited])
        if let cancellingOrders = defaults.stringArray(forKey: UserDefaultsKeys.cancellingOrders.rawValue) {
            openOrders.forEach { (order) in
                if !cancellingOrders.contains(order.originalOrder.hash) {
                    result = true
                }
            }
        } else {
            result = openOrders.count > 0
        }
        return result
    }

    func getOrdersFromServer(pageIndex: UInt, pageSize: UInt = 50, completionHandler: @escaping (_ error: Error?) -> Void) {
        if let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getOrders(owner: owner, pageIndex: pageIndex, pageSize: pageSize) { orders, error in
                guard let orders = orders, error == nil else {
                    self.orders = []
                    completionHandler(error)
                    return
                }

                if pageIndex == 1 {
                    self.orders = orders
                } else {
                    self.orders += orders
                }
                completionHandler(error)
            }
        }
    }
}
