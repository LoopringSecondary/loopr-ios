//
//  PriceQuoteDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/13.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class PriceQuoteDataManager {
    
    static let shared = PriceQuoteDataManager()
    var priceQuote: PriceQuote?
    
    private init() {
        self.priceQuote = nil
    }
    
    // this func should be called every 10 secs when emitted
    func onPriceQuoteResponse(json: JSON) {
        
        priceQuote = PriceQuote(json: json)
        guard let price = priceQuote else { return }
        BalanceDataManager.shared.totalBalance = 0
        for priceToken in price.tokens {
            for case let (index, token) in BalanceDataManager.shared.tokens.enumerated() where token.symbol.lowercased() == priceToken.symbol.lowercased() {
                if let balance = Double(token.balance) {
                    token.display = balance * priceToken.price
                    BalanceDataManager.shared.tokens[index] = token
                    BalanceDataManager.shared.totalBalance += token.display
                }
            }
        }
    }
}
