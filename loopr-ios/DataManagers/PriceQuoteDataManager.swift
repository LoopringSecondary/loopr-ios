//
//  PriceQuoteDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/13.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class PriceQuoteDataManager {
    
    static let shared = PriceQuoteDataManager()
    private var priceQuote: PriceQuote?
    
    private init() {
        self.priceQuote = nil
    }
    
    func getPriceQuote() -> PriceQuote? {
        return self.priceQuote ?? nil
    }
    
    func getPriceBySymbol(of symbol: String) -> Double? {
        var result: Double? = nil
        if let price = priceQuote {
            for case let token in price.tokens where token.symbol.lowercased() == symbol.lowercased() {
                result = token.price
                break
            }
        }
        return result
    }
    
    // MARK: whether stop method is useful?
    func startGetPriceQuote(_ currency: String) {
        LoopringSocketIORequest.getPriceQuote(currency: currency)
    }
    
    // this func should be called every 10 secs when emitted
    func onPriceQuoteResponse(json: JSON) {
        priceQuote = PriceQuote(json: json)
        NotificationCenter.default.post(name: .priceQuoteResponseReceived, object: nil)
    }
}
