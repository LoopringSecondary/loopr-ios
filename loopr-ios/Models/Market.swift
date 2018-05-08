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
    
    var name: String
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
        name = json["market"].stringValue
        let tokens = json["market"].stringValue.components(separatedBy: "-")
        guard tokens.count == 2 else {
            return nil
        }
        icon = UIImage(named: tokens[0]) ?? nil
        changeInPat24 = json["change"].stringValue
        tradingPair = TradingPair(tokens[0], tokens[1])
        description = "\(tokens[0])" + "/" + "\(tokens[1])"
        balance = json["last"].doubleValue
        volumeInPast24 = json["amount"].doubleValue
        
        let change = json["change"].stringValue
        if change.isEmpty || change == "0.00%" {
            changeInPat24 = "0.00%"
        } else if change.first! == "-" {
            changeInPat24 = "↓" + change.dropFirst()
        } else {
            changeInPat24 = "↑" + change
        }
        if let price = PriceDataManager.shared.getPriceBySymbol(of: tradingPair.tradingA) {
            display = price.currency
        } else {
            return nil
        }
    }
    
    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.tradingPair == rhs.tradingPair
    }

}
