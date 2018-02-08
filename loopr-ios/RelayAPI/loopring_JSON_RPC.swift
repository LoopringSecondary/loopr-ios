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
    
    public static func getBalance(owner: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getBalance"
        body["params"] = [["owner": owner]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }

    static func getOrders(ringHash: String? = nil, pageIndex: UInt = 0, pageSize: UInt = 20, completionHandler: @escaping (_ orders: [Order], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getOrders"
        body["params"] = [["ringHash": ringHash, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
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

    static func getDepth(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getDepth"
        body["params"] = [["market": "LRC-WETH", "length": 0]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }

    // FIXME: Get an error - "The method loopring_getTickers does not exist\/is not available"
    static func getTickers(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTickers"
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    static func getFills(market: String, owner: String, orderHash: String, ringHash: String, pageIndex: UInt, pageSize: UInt, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getFills"
        body["params"] = [["market": market]]
        
        // TODO: support other params
        /*
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["params"]["owner"] = JSON(owner)
        body["params"]["orderHash"] = JSON(orderHash)
        body["params"]["ringHash"] = JSON(ringHash)
        body["params"]["pageIndex"] = JSON(pageIndex)
        body["params"]["pageSize"] = JSON(pageSize)
        */
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // FIXME:
    /*
    response = {
        "id" : "1a715e2557abc0bd",
        "error" : {
            "code" : -32602,
            "message" : "invalid argument 0: json: cannot unmarshal object into Go value of type string"
        },
        "jsonrpc" : "2.0"
    }
    */
    static func getTrend(market: String, interval: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTrend"
        body["params"] = [["market": market, "interval": interval]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    static func getRingMined(ringHash: String, pageIndex: UInt, pageSize: UInt, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getRingMined"
        body["params"] = [["ringHash": ringHash, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // FIXME:
    /*
     response = {
        "id" : "1a715e2557abc0bd",
        "error" : {
            "code" : -32602,
            "message" : "invalid argument 0: json: cannot unmarshal object into Go value of type string"
     },
        "jsonrpc" : "2.0"
     }
     */
    static func getCutoff(address: String?, blockNumber: String = "latest", completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getCutoff"
        body["params"] = [["address": address, "blockNumber": blockNumber]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // FIXME:
    /*
    response = {
        "id" : "1a715e2557abc0bd",
        "error" : {
            "code" : -32602,
            "message" : "invalid argument 0: json: cannot unmarshal object into Go value of type string"
        },
        "jsonrpc" : "2.0"
    }
    */
    static func getPriceQuote(currency: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPriceQuote"
        body["params"] = [["currency": currency]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // FIXME:
    static func getEstimatedAllocatedAllowance(owner: String? = nil, token: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getEstimatedAllocatedAllowance"
        body["params"] = [["owner": owner, "token": token]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    static func getSupportedMarket(completionHandler: @escaping (_ market: [Market], _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["method"] = "loopring_getSupportedMarket"
        body["params"] = [["contractVersion": contractVersion]]
        body["id"] = "1a715e2557abc0bd"

        Request.send(body: body) { data, response, error in
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
    
    // FIXME:
    /*
    response = {
        "id" : "1a715e2557abc0bd",
        "error" : {
            "code" : -32601,
            "message" : "The method loopring_getPortfolio does not exist\/is not available"
        },
        "jsonrpc" : "2.0"
    }
    */
    static func getPortfolio(owner: String, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getPortfolio"
        body["params"] = [["owner": owner]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // FIXME:
    /*
    response = {
        "id" : "1a715e2557abc0bd",
        "error" : {
            "code" : -32601,
            "message" : "The method loopring_getTransactions does not exist\/is not available"
        },
        "jsonrpc" : "2.0"
    }
    */
    static func getTransactions(owner: String, thxHash: String, pageIndex: UInt = 1, pageSize: UInt = 10, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTransactions"
        body["params"] = [["owner": owner, "thxHash": thxHash, "pageIndex": pageIndex, "pageSize": pageSize]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
}
