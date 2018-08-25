//
//  PriceQuoteDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/3/13.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class PriceDataManager {
    
    static let shared = PriceDataManager()
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
    
    func getPrice(of symbol: String) -> Double? {
        var result: Double?
        if let price = priceQuote {
            for case let token in price.tokens where token.symbol.lowercased() == symbol.lowercased() {
                result = token.price
                break
            }
        }
        return result
    }
    
    func getPrice(of symbol: String, by amount: Double) -> String? {
        var result: String?
        if let price = getPrice(of: symbol) {
            result = (price * amount).currency
        }
        return result
    }
    
    func startGetPriceQuote() {
        let currency = SettingDataManager.shared.getCurrentCurrency()
        LoopringAPIRequest.getPriceQuote(currency: currency.name, completionHandler: { (priceQuote, error) in
            print("receive LoopringAPIRequest.getPriceQuote ....")
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            PriceDataManager.shared.setPriceQuote(newPriceQuote: priceQuote!)
        })
        
        // start socket io
        LoopringSocketIORequest.getPriceQuote(currency: currency.name)
    }
    
    func stopGetPriceQuote() {
        LoopringSocketIORequest.endPriceQuote()
    }
    
    // Socket IO: this func should be called every 10 secs when emitted
    func onPriceQuoteResponse(json: JSON) {
        print("Receive onPriceQuoteResponse")
        priceQuote = PriceQuote(json: json)
        NotificationCenter.default.post(name: .priceQuoteResponseReceived, object: nil)
    }
}
