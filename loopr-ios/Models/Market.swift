//
//  Market.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Market: Equatable, CustomStringConvertible {
    
    var icon: UIImage?
    var description: String
    final let tradingPair: TradingPair
    var balance: Double
    var display: Double
    var volumeInPast24: Double
    var changeInPat24: String
    
    func isFavorite() -> Bool {
        return MarketDataManager.shared.getFavoriteMarketKeys().contains(description)
    }

    static func == (lhs: Market, rhs: Market) -> Bool {
        return lhs.tradingPair == rhs.tradingPair
    }

    init?(json: JSON) {
        let tokens = json["market"].stringValue.components(separatedBy: "-")
        guard tokens.count == 2 else {
            return nil
        }
        self.display = 0
        self.icon = UIImage(named: tokens[0]) ?? nil
        self.changeInPat24 = json["change"].stringValue
        self.tradingPair = TradingPair(tokens[0], tokens[1])
        self.description = "\(tokens[0])" + " / " + "\(tokens[1])"
        self.balance = json["last"].doubleValue
        self.volumeInPast24 = json["amount"].doubleValue
    }
}
