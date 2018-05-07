//
//  OrderDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

class OrderDataManager {

    static let shared = OrderDataManager()

    private var owner: String?
    private var orders: [Order]
    private var dateOrders: [String: [Order]]

    private init() {
        orders = []
        dateOrders = [:]
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
        if let owner = self.owner {
            LoopringAPIRequest.getOrders(owner: owner) { orders, error in
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
