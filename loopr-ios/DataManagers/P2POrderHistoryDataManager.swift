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
    
    private init() {
        orders = []
        dateOrders = [:]
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
    
    func getOrdersFromServer(completionHandler: @escaping (_ orders: [Order]?, _ error: Error?) -> Void) {
        if let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getOrders(owner: owner, orderType: "p2p_order") { orders, error in
                guard let orders = orders, error == nil else {
                    return
                }
                self.dateOrders = [:]
                for order in orders {
                    let time = UInt(order.originalOrder.validSince)
                    let valid = DateUtil.convertToDate(time, format: "MM/dd/yyyy")
                    if self.dateOrders[valid] == nil {
                        self.dateOrders[valid] = []
                    }
                    self.dateOrders[valid]!.append(order)
                }
                self.orders = orders
                completionHandler(orders, error)
            }
        }
    }

}
