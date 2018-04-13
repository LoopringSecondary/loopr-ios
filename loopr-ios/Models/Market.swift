//
//  Market.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

class Market: Equatable, CustomStringConvertible {
    
    var icon: UIImage?
    var description: String
    final let tradingPair: TradingPair
    
    var balance: Double
    var display: String
    var volumeInPast24: Double
    var changeInPat24: String
    
    func isFavorite() -> Bool {
        return MarketDataManager.shared.getFavoriteMarketKeys().contains(description)
    }

    init?(json: JSON) {
        let tokens = json["market"].stringValue.components(separatedBy: "-")
        guard tokens.count == 2 else {
            return nil
        }

        icon = UIImage(named: tokens[0]) ?? nil
        changeInPat24 = json["change"].stringValue
        tradingPair = TradingPair(tokens[0], tokens[1])
        description = "\(tokens[0])" + " / " + "\(tokens[1])"
        balance = json["last"].doubleValue
        volumeInPast24 = json["amount"].doubleValue

        let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: tradingPair.tradingA) ?? 0
        display = String(price)
    }
    
    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.tradingPair == rhs.tradingPair
    }

}
