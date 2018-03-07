//
//  JSON_RPC.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

// https://github.com/Loopring/relay/blob/wallet_v2/LOOPRING_RELAY_API_SPEC_V2.md#loopring_getorders
class loopring_JSON_RPC {
    
    static let contractVersion = "v1.0"
    
    static let url = URL(string: "https://relay1.loopring.io/rpc")!
    
    // READY
    public static func getBalance(owner: String? = nil, completionHandler: @escaping (_ tokens: [Token]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getBalance"
        body["params"] = [["contractVersion": contractVersion, "owner": owner]]
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            let json = JSON(data)
            var tokens: [Token] = []
            let offerData = json["result"]["tokens"]
            for subJson in offerData.arrayValue {
                let token = Token(json: subJson)
                tokens.append(token)
            }
            completionHandler(tokens, error)
        }
    }

    // TODO: How to get a list of orders for an address
    static func getOrders(owner: String? = nil, orderHash: String? = nil, status: String? = nil, market: String? = nil, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ orders: [Order], _ error: Error?) -> Void) {
        
        var body: JSON = JSON()
        
        body["method"] = "loopring_getOrders"
        body["params"] = [["owner": owner, "orderHash": orderHash, "contractVersion": contractVersion, "status": status, "market": market, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["id"] = "1a715e2557abc0bd"
        
        print(body)
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler([], error)
                return
            }
            var orders: [Order] = []
            let json = JSON(data)
            let resultJson = json["result"]
            let offerData = resultJson["data"]
            for subJson in offerData.arrayValue {
                let originalOrderJson = subJson["originalOrder"]
                let originalOrder = OriginalOrder(json: originalOrderJson)
                
                // TODO: how to handle unknown status?
                let orderStatus = OrderStatus(rawValue: subJson["status"].stringValue)!
                let dealtAmountB = subJson["dealtAmountB"].stringValue
                let dealtAmountS = subJson["dealtAmountS"].stringValue
                let order = Order(originalOrder: originalOrder, orderStatus: orderStatus, dealtAmountB: dealtAmountB, dealtAmountS: dealtAmountS)
                
                orders.append(order)
            }
            completionHandler(orders, nil)
        }
    }

    // READY
    static func getDepth(completionHandler: @escaping (_ depth: Depth?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getDepth"
        body["params"] = [["contractVersion": contractVersion, "market": "LRC-WETH", "length": 10]]
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
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

    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getTickers(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTickers"
        body["params"] = [["contractVersion": contractVersion]]
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // READY
    static func getFills(market: String, owner: String?, orderHash: String?, ringHash: String?, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ trades: [Trade], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getFills"
        body["params"] = [["market": market, "contractVersion": contractVersion, "owner": owner, "orderHash": orderHash, "ringHash": ringHash]]
        body["id"] = "1a715e2557abc0bd"
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            var trades: [Trade] = []
            let json = JSON(data)
            let resultJson = json["result"]
            let offerData = resultJson["data"]
            for subJson in offerData.arrayValue {
                let trade = Trade(json: subJson)
                trades.append(trade)
            }
            completionHandler(trades, nil)
        }
    }
    
    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getTrend(market: String, interval: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTrend"
        body["params"] = [["market": market, "interval": interval]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }

    // READY
    static func getRingMined(ringHash: String? = nil, pageIndex: UInt = 1, pageSize: UInt = 20, completionHandler: @escaping (_ minedRings: [MinedRing]?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getRingMined"
        body["params"] = [["ringHash": ringHash, "contractVersion": contractVersion, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
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
            completionHandler(minedRings, error)
        }
    }
    
    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getCutoff(address: String?, blockNumber: String = "latest", completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getCutoff"
        body["params"] = [["contractVersion": contractVersion, "address": address, "blockNumber": blockNumber]]
        body["id"] = "1a715e2557abc0bd"
        
        print(body)
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getPriceQuote(currency: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPriceQuote"
        body["params"] = [["currency": currency]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getEstimatedAllocatedAllowance(owner: String? = nil, token: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getEstimatedAllocatedAllowance"
        body["params"] = [["owner": owner, "token": token]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // READY
    static func getSupportedMarket(completionHandler: @escaping (_ market: [Market], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getSupportedMarket"
        body["params"] = [["contractVersion": contractVersion]]
        body["id"] = "1a715e2557abc0bd"
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler([], error)
                return
            }
            
            var markets: [Market] = []
            
            let json = JSON(data)
            let resultJson = json["result"]
            for tradingPairStringJson in resultJson.arrayValue {
                let tradingPairString = tradingPairStringJson.stringValue
                let tokens = tradingPairString.components(separatedBy: "-")
                guard tokens.count == 2 else {
                    // TODO: how to handle invalid results
                    continue
                }
                let market = Market(tradingA: tokens[0], tradingB: tokens[1])
                markets.append(market)
            }
            completionHandler(markets, error)
        }
    }
    
    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getPortfolio(owner: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPortfolio"
        body["params"] = [["owner": owner]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // TODO: backend will modify later in test env, and then complete this method --kenshin
    static func getTransactions(owner: String, thxHash: String, pageIndex: UInt = 1, pageSize: UInt = 10, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTransactions"
        body["params"] = [["owner": owner, "thxHash": thxHash, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
}
