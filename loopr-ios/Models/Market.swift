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
        
        if let price = PriceQuoteDataManager.shared.getPriceBySymbol(of: tradingPair.tradingA) {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.locale = NSLocale.current
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            let formattedNumber = currencyFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
            display = formattedNumber
        } else {
            return nil
        }
    }
    
    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.tradingPair == rhs.tradingPair
    }

}
