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
class MarketDepthDataManager {

    static let shared = MarketDepthDataManager()

    var market: String?
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

    func getDepthFromServer(market: String, completionHandler: @escaping (_ buyDepths: [Depth], _ sellDepths: [Depth], _ error: Error?) -> Void) {

        LoopringAPIRequest.getDepths(market: market, length: 20) { (buyDepths, sellDepths, error) in
            guard buyDepths != nil && sellDepths != nil && error == nil else { return }
            self.market = market
            self.buys = buyDepths!
            self.sells = sellDepths!
            completionHandler(self.buys, self.sells, nil)
        }
    }

}
