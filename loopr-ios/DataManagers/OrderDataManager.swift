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

    private var owner: String?
    private var orders: [Order]
    private var dataOrders: [String: [Order]]
    
    private init() {
        orders = []
        dataOrders = [:]
        owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address
    }
    
    func getOrders(orderStatuses: [OrderStatus]? = nil) -> [Order] {
        guard let orderStatuses = orderStatuses else {
            return orders
        }
        return orders.filter { (order) -> Bool in
            orderStatuses.contains(order.orderStatus)
        }
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
            return dataOrders
        }
        var result: [String: [Order]] = [:]
        for (date, orders) in dataOrders {
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
    
    func getDataOrders(token: String? = nil) -> [String: [Order]] {
        guard let token = token else {
            return dataOrders
        }
        var result: [String: [Order]] = [:]
        for (date, orders) in dataOrders {
            for order in orders {
                let pair = order.originalOrder.market.components(separatedBy: "-")
                if pair[0].lowercased() == token.lowercased() {
                    if result[date] == nil {
                        result[date] = []
                    }
                    result[date]!.append(order)
                }
            }
        }
        return result
    }

    func getOrdersFromServer() {
        
        // TODO: modify here
        if let owner = self.owner {
            LoopringAPIRequest.getOrders(owner: nil) { orders, error in
                guard let orders = orders, error == nil else {
                    return
                }
                self.dataOrders = [:]
                for order in orders {
                    let time = order.originalOrder.validSince
                    if self.dataOrders[time] == nil {
                        self.dataOrders[time] = []
                    }
                    self.dataOrders[time]!.append(order)
                }
                self.orders = orders
            }
        }
    }
}
