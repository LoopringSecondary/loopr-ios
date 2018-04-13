//
//  JSON_RPC.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

// https://github.com/Loopring/relay/blob/wallet_v2/LOOPRING_RELAY_API_SPEC_V2.md#loopring_getorders
class LoopringAPIRequest {

    // READY
    public static func getBalance(owner: String? = nil, completionHandler: @escaping (_ assets: [Asset]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getBalance"
        body["params"] = [["contractVersion": RelayAPIConfiguration.contractVersion, "owner": owner]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            
            let json = JSON(data)
            var assets: [Asset] = []
            let offerData = json["result"]["tokens"]
            for subJson in offerData.arrayValue {
                let asset = Asset(json: subJson)
                assets.append(asset)
            }
            completionHandler(assets, error)
        }
    }

    // TODO: how to handle unknown status?
    static func getOrders(owner: String? = nil, orderHash: String? = nil, status: String? = nil, market: String? = nil, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ orders: [Order]?, _ error: Error?) -> Void) {
        
        var body: JSON = JSON()
        
        body["method"] = "loopring_getOrders"
        body["params"] = [["owner": owner, "orderHash": orderHash, "contractVersion": RelayAPIConfiguration.contractVersion, "status": status, "market": market, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["id"] = JSON(UUID().uuidString)
        
        print(body)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler([], error)
                return
            }
            var orders: [Order] = []
            let json = JSON(data)
            let offerData = json["result"]["data"]
            print(json)
            print(offerData)
            
            for subJson in offerData.arrayValue {
                let originalOrderJson = subJson["originalOrder"]
                let originalOrder = OriginalOrder(json: originalOrderJson)
                let orderStatus = OrderStatus(rawValue: subJson["status"].stringValue) ?? OrderStatus.unknown
                let dealtAmountB = subJson["dealtAmountB"].stringValue
                let dealtAmountS = subJson["dealtAmountS"].stringValue
                let order = Order(originalOrder: originalOrder, orderStatus: orderStatus, dealtAmountB: dealtAmountB, dealtAmountS: dealtAmountS)
                orders.append(order)
            }
            completionHandler(orders, nil)
        }
    }

    // READY
    static func getDepth(market: String, length: UInt, completionHandler: @escaping (_ depth: Depth?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getDepth"
        body["params"] = [["contractVersion": RelayAPIConfiguration.contractVersion, "market": market, "length": length]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]["depth"]
            let buyContent = offerData["buy"].arrayObject as! [[String]]
            let sellContent = offerData["sell"].arrayObject as! [[String]]
            let depth = Depth(buyOrders: buyContent, sellOrders: sellContent)
            completionHandler(depth, nil)
        }
    }

    // READY
    static func getTicker(completionHandler: @escaping (_ tikers: [Ticker]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTicker"
        body["params"] = [["contractVersion": RelayAPIConfiguration.contractVersion]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            var tickers: [Ticker] = []
            let json = JSON(data)
            let offerData = json["result"]
            for subJson in offerData.arrayValue {
                let ticker = Ticker(json: subJson)
                tickers.append(ticker)
            }
            completionHandler(tickers, nil)
        }
    }
    
    // READY
    static func getFills(market: String, owner: String?, orderHash: String?, ringHash: String?, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ trades: [Trade]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getFills"
        body["params"] = [["market": market, "contractVersion": RelayAPIConfiguration.contractVersion, "owner": owner, "orderHash": orderHash, "ringHash": ringHash]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            var trades: [Trade] = []
            let json = JSON(data)
            let offerData = json["result"]["data"]
            for subJson in offerData.arrayValue {
                let trade = Trade(json: subJson)
                trades.append(trade)
            }
            completionHandler(trades, nil)
        }
    }
    
    // READY
    static func getTrend(market: String, interval: String, completionHandler: @escaping (_ trends: [Trend]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTrend"
        body["params"] = [["market": market, "interval": interval]]
        body["params"]["contractVersion"] = JSON(RelayAPIConfiguration.contractVersion)
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var trends: [Trend] = []
            let json = JSON(data)
            let offerData = json["result"]
            for subJson in offerData.arrayValue {
                let trend = Trend(json: subJson)
                trends.append(trend)
            }
            completionHandler(trends, nil)
        }
    }

    // READY
    static func getRingMined(ringHash: String? = nil, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ minedRings: [MinedRing]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getRingMined"
        body["params"] = [["ringHash": ringHash, "contractVersion": RelayAPIConfiguration.contractVersion, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]["data"]
            var minedRings: [MinedRing] = []
            for subJson in offerData.arrayValue {
                let minedRing = MinedRing(json: subJson)
                minedRings.append(minedRing)
            }
            completionHandler(minedRings, nil)
        }
    }
    
    // READY
    static func getCutoff(address: String, blockNumber: String = "latest", completionHandler: @escaping (_ date: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getCutoff"
        body["params"] = [["contractVersion": RelayAPIConfiguration.contractVersion, "address": address, "blockNumber": blockNumber]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            let date = Transaction.convertToDate(offerData.uIntValue)
            completionHandler(date, nil)
        }
    }
    
    // READY
    static func getPriceQuote(currency: String, completionHandler: @escaping (_ price: PriceQuote?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPriceQuote"
        body["params"] = [["currency": currency]]
        body["params"]["contractVersion"] = JSON(RelayAPIConfiguration.contractVersion)
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            let price = PriceQuote(json: offerData)
            completionHandler(price, nil)
        }
    }
    
    // READY
    static func getEstimatedAllocatedAllowance(owner: String, token: String, completionHandler: @escaping (_ result: Double?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getEstimatedAllocatedAllowance"
        body["params"] = [["owner": owner, "token": token]]
        body["params"]["contractVersion"] = JSON(RelayAPIConfiguration.contractVersion)
        body["id"] = JSON(UUID().uuidString)

        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let json = JSON(data)
            let result = json["result"].stringValue
            if let amount = CurrentAppWalletDataManager.shared.getAmount(of: token, from: result) {
                completionHandler(amount, nil)
            }
        }
    }
    
    static func getSupportedTokens(completionHandler: @escaping (_ tokens: [Token]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getSupportedTokens"
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var tokens: [Token] = []
            let json = JSON(data)
            let offerData = json["result"]
            for subJson in offerData.arrayValue {
                let token = Token(json: subJson)
                tokens.append(token)
            }
            completionHandler(tokens, nil)
        }
    }
    
    // READY
    static func getSupportedMarket(completionHandler: @escaping (_ pairs: [TradingPair]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getSupportedMarket"
        body["params"] = [["contractVersion": RelayAPIConfiguration.contractVersion]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            var pairs: [TradingPair] = []
            let json = JSON(data)
            let resultJson = json["result"]
            for pair in resultJson.arrayValue {
                let tokens = pair.stringValue.components(separatedBy: "-")
                let pair = TradingPair(tokens[0], tokens[1])
                pairs.append(pair)
            }
            completionHandler(pairs, nil)
        }
    }
    
    // READY
    static func getTransactions(owner: String, symbol: String, thxHash: String?, pageIndex: UInt = 1, pageSize: UInt = 10, completionHandler: @escaping (_ transactions: [Transaction]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTransactions"
        body["params"] = [["owner": owner, "symbol": symbol, "thxHash": thxHash, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["params"]["contractVersion"] = JSON(RelayAPIConfiguration.contractVersion)
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]["data"]
            var transactions: [Transaction] = []
            for subJson in offerData.arrayValue {
                let transaction = Transaction(json: subJson)
                transactions.append(transaction)
            }
            completionHandler(transactions, nil)
        }
    }
    
    // READY -- must be invoked from unlock method
    static func unlockWallet(owner: String, completionHandler: @escaping (_ result: String?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_unlockWallet"
        body["params"] = [["owner": owner]]
        body["id"] = JSON(UUID().uuidString)
        Request.send(body: body, url: RelayAPIConfiguration.rpcURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            let offerData = json["result"]
            completionHandler(offerData.description, nil)
        }
    }
}
