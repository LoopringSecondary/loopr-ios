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
    private var dateOrders: [String: [Order]]
    
    // changed to true when a P2P order is submitted.
    var shouldReloadData: Bool = false
    
    private init() {
        orders = []
        dateOrders = [:]
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
    
    func getDateOrders(orderStatuses: [OrderStatus]? = nil) -> [String: [Order]] {
        guard let orderStatuses = orderStatuses else {
            return dateOrders
        }
        var result: [String: [Order]] = [:]
        for (date, orders) in dateOrders {
            var temp: [Order] = []
            for order in orders {
                if orderStatuses.contains(where: { (status) -> Bool in
                    order.orderStatus == status
                }) {
                    temp.append(order)
                }
            }
            if !temp.isEmpty {
                result[date] = temp
            }
        }
        return result
    }
    
    func getDateOrders(tokenSymbol: String? = nil) -> [String: [Order]] {
        guard let tokenSymbol = tokenSymbol else {
            return dateOrders
        }
        var result: [String: [Order]] = [:]
        for (date, orders) in dateOrders {
            for order in orders {
                let pair = order.originalOrder.market.components(separatedBy: "-")
                if pair[0].lowercased() == tokenSymbol.lowercased() {
                    if result[date] == nil {
                        result[date] = []
                    }
                    result[date]!.append(order)
                }
            }
        }
        return result
    }
    
    func getOrdersFromServer(pageIndex: UInt, pageSize: UInt = 50, completionHandler: @escaping (_ orders: [Order], _ error: Error?) -> Void) {
        if let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getOrders(owner: owner, orderType: OrderType.p2pOrder.rawValue, pageIndex: pageIndex, pageSize: pageSize) { orders, error in
                guard let orders = orders, error == nil else {
                    self.dateOrders = [:]
                    self.orders = []
                    completionHandler([], error)
                    return
                }
                // No need to reset
                // self.dateOrders = [:]
                for order in orders {
                    let time = UInt(order.originalOrder.validSince)
                    let valid = DateUtil.convertToDate(time, format: "yyyy-MM-dd")
                    if self.dateOrders[valid] == nil {
                        self.dateOrders[valid] = []
                    }
                    if let indexOfOrder = self.dateOrders[valid]?.index(of: order) {
                        self.dateOrders[valid]![indexOfOrder] = order
                    } else {
                        self.dateOrders[valid]!.append(order)
                    }
                }

                // Sort
                var newDateOrders: [String: [Order]] = [:]
                for (date, orders) in self.dateOrders {
                    newDateOrders[date] = orders.sorted(by: { (a, b) -> Bool in
                        return a.originalOrder.validSince > b.originalOrder.validSince
                    })
                }
                self.dateOrders = newDateOrders
                
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
