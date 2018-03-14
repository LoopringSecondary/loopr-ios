//
//  BalanceDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/13.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class BalanceDataManager {
    
    static let shared = BalanceDataManager()
    var tokens: [Token]
    var totalBalance: Double
    
    private init() {
        self.tokens = []
        self.totalBalance = 0
    }
    
    // this func should be called every 10 secs when emitted
    func onBalanceResponse(json: JSON) {
        
        totalBalance = 0
        for subJson in json["tokens"].arrayValue {
            let token = Token(json: subJson)
            if let price = PriceQuoteDataManager.shared.priceQuote {
                for case let priceToken in price.tokens where priceToken.symbol.lowercased() == token.symbol.lowercased() {
                    if let balance = Double(token.balance) {
                        token.display = balance * priceToken.price
                        totalBalance += token.display
                    }
                }
            }
            tokens.append(token)
        }
    }
}
