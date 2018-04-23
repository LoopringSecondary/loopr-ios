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
    
    func setPriceQuote(newPriceQuote: PriceQuote) {
        priceQuote = newPriceQuote
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
    
    func startGetPriceQuote() {
        let currency = SettingDataManager.shared.getCurrentCurrency()
        LoopringSocketIORequest.getPriceQuote(currency: currency.name)
    }
    
    func stopGetPriceQuote() {
        LoopringSocketIORequest.endPriceQuote()
    }
    
    // Socket IO: this func should be called every 10 secs when emitted
    func onPriceQuoteResponse(json: JSON) {
        priceQuote = PriceQuote(json: json)
        NotificationCenter.default.post(name: .priceQuoteResponseReceived, object: nil)
    }
}
