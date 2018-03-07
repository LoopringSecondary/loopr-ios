//
//  eth_JSON_RPC.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

class eth_JSON_RPC {
    
    static let url = URL(string: "http://13.112.62.24/eth")!
    
    static func eth_call(from: String?, to: String, gas: UInt?, gasPrice: UInt?, value: UInt?, data: String?, completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "eth_call"
        body["params"] = [["from": from, "to": to, "gas": gas, "gasPrice": gasPrice, "value": value, "data": data]]
        body["id"] = "1a715e2557abc0bd"
        print(body)
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            print(data)
            
            let json = JSON(data)
            var tokens: [Token] = []
            let offerData = json["result"]["tokens"]
            for subJson in offerData.arrayValue {
                let token = Token(json: subJson)
                tokens.append(token)
            }
            completionHandler(data, response, error)
        }
    }

    // TODO:
    public static func eth_getTransactionCount() {
        
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
    public static func eth_getBalance(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "eth_getBalance"
        body["params"] = [["owner": "0x407d73d8a49eeb85d32cf465507dd71d507100c1"]]
        body["params"]["contractVersion"] = "v1.0"
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body, url: url) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            print(data)
            completionHandler(data, response, error)
        }
    }
    
    // TODO:
    public static func eth_gasPrice() {
        
    }
    
    // TODO:
    public static func eth_senxdRawTransaction() {
        
    }
    
    // TODO:
    public static func eth_estimateGas() {
        
    }
}
