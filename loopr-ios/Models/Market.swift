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
    
    var exchange: String
    var name: String
    var icon: UIImage?
    var description: String
    let tradingPair: TradingPair
    var balance: Double
    var display: String
    var volumeInPast24: Double
    var changeInPat24: String
    var tag: TickerTag

    // loopring_getTickers
    var open: Double
    var close: Double
    var last: Double
    var low: Double
    var high: Double
    var buy: Double
    var sell: Double
    
    func isFavorite() -> Bool {
        return MarketDataManager.shared.getFavoriteMarketKeys().contains(description)
    }

    init?(json: JSON) {
        exchange = json["exchange"].string ?? ""
        name = json["market"].stringValue
        let tokens = json["market"].stringValue.components(separatedBy: "-")
        guard tokens.count == 2 else {
            return nil
        }
        icon = UIImage(named: tokens[0]) ?? nil
        changeInPat24 = json["change"].stringValue
        tradingPair = TradingPair(tokens[0], tokens[1])
        description = "\(tokens[0])" + "-" + "\(tokens[1])"
        balance = json["last"].doubleValue
        volumeInPast24 = json["vol"].doubleValue
        tag = TickerTag(rawValue: json["label"].stringValue) ?? .unknown
        let change = json["change"].stringValue
        if change.isEmpty || change == "0.00%" {
            changeInPat24 = "0.00%"
        } else if change.first! == "-" {
            changeInPat24 = "↓" + change.dropFirst()
        } else {
            changeInPat24 = "↑" + change
        }
        if let price = PriceDataManager.shared.getPrice(of: tradingPair.tradingA) {
            display = price.currency
        } else {
            return nil
        }
        
        open = json["open"].double ?? 0.0
        close = json["close"].double ?? 0.0
        last = json["last"].double ?? 0.0
        low = json["low"].double ?? 0.0
        high = json["high"].double ?? 0.0
        buy = json["buy"].double ?? 0.0
        sell = json["sell"].double ?? 0.0
    }
    
    func getExchangeDescription() -> String {
        switch exchange {
        case "binance":
            return "Binance"
        case "okex":
            return "OKEx"
        default:
            return exchange.capitalized
        }
    }
    
    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.tradingPair == rhs.tradingPair
    }

}
