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
class DepthDataManager {

    static let shared = DepthDataManager()

    let itemCount = UIDevice.current.iPhoneX ? 5 : 4
    private var sells: [Depth] = []
    private var buys: [Depth] = []
    
    private init() {
        
    }
    
    func getSells() -> [Depth] {
        return sells
    }
    
    func getBuys() -> [Depth] {
        return buys
    }

    // TODO: Not sure how orders are sorted in JSON RPC API. So send two requests.
    func getDepthFromServer(market: String, completionHandler: @escaping (_ buyDepths: [Depth], _ sellDepths: [Depth], _ error: Error?) -> Void) {

        LoopringAPIRequest.getDepths(market: market, length: 1) { (buyDepths, sellDepths, error) in
            guard buyDepths != nil && sellDepths != nil && error == nil else { return }
            
            completionHandler(self.getSells(), self.getBuys(), nil)
        }
        
        /*
        LoopringAPIRequest.getOrders(owner: nil, status: OrderStatus.opened.rawValue, market: market) { orders, error in
            guard let orders = orders, error == nil else {
                return
            }
            /*
            let buyOrders = orders.filter({ (order) -> Bool in
                // TODO: looks like website doesn't show the order that dealtAmountS and dealtAmountB are not zero.
                order.originalOrder.side == "buy" && order.dealtAmountS == 0 && order.dealtAmountB == 0
            })
            self.buys = OrderBookDataManager.aggregateOrderToOrderBook(orders: buyOrders, side: "buy")

            let sellOrders = orders.filter({ (order) -> Bool in
                // TODO: looks like website doesn't show the order that dealtAmountS and dealtAmountB are not zero.
                order.originalOrder.side == "sell" && order.dealtAmountS == 0 && order.dealtAmountB == 0
            })
            self.sells = OrderBookDataManager.aggregateOrderToOrderBook(orders: sellOrders, side: "sell")

            completionHandler(self.getSells(), self.getBuys(), nil)
            */
        }
        */
    }

}
