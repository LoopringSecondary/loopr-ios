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
class JSON_RPC {
    
    static let contractVersion = "v1.0"
    
    public static func getBalance(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getBalance"
        body["params"] = [["owner": "0x847983c3a34afa192cfee860698584c030f4c9db1"]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }

    static func getOrders(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getOrders"
        body["params"] = [["ringHash": nil, "pageIndex": 0, "pageSize": 20]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }

    static func getDepth(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getDepth"
        body["params"] = [["market": "LRC-WETH", "length": 0]]
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }

    static func getTickers(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getTickers"
        body["params"]["contractVersion"] = JSON(contractVersion)
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // TODO:
    static func getFills(completionHandler: @escaping CompletionHandler) {
        
    }
    
    // TODO:
    static func getTrend(completionHandler: @escaping CompletionHandler) {
        
    }
    
    // TODO:
    static func getRingMined(completionHandler: @escaping CompletionHandler) {
        
    }
}
