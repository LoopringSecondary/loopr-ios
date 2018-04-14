//
//  eth_JSON_RPC.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class EthereumAPIRequest {

    static func removeNilParams(json: inout JSON) {
        
        if let dict = json.dictionary {
            let dictToRemove = dict.filter { (key, _) -> Bool in
                return dict[key]!.type == .unknown
            }
            for key in dictToRemove.keys {
                json.dictionaryObject?.removeValue(forKey: key)
            }
        }
    }
    
    static func invoke<T: Initable>(method: String, withBody body: inout JSON, _ completionHandler: @escaping (_ response: T?, _ error: Error?) -> Void) {
        
        body["method"] = JSON(method)
        body["id"] = JSON(UUID().uuidString)
        
        Request.send(body: body, url: RelayAPIConfiguration.ethURL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completionHandler(nil, error)
                return
            }
            
            // TODO: need to check the status code.
            
            var json = JSON(data)
            if json["result"] != JSON.null {
                completionHandler(T.init(json["result"]), nil)
            } else if json["error"] != JSON.null {
                var userInfo: [String: Any] = [:]
                userInfo["code"] = json["error"]["code"]
                userInfo["message"] = json["error"]["message"]
                let error = NSError(domain: method, code: 0, userInfo: userInfo)
                completionHandler(nil, error)
            }
        }
    }
    
    // READY
    static func eth_call(from: String?, to: String, gas: UInt?, gasPrice: UInt?, value: UInt?, data: String?, block: DefaultBlock, completionHandler: @escaping (_ response: SimpleRespond?, _ error: Error?) -> Void) {
        
        var body: JSON = JSON()
        body["params"] = [["from": from, "to": to, "gas": gas, "gasPrice": gasPrice, "value": value, "data": data], block.description()]
        removeNilParams(json: &body["params"][0])
        self.invoke(method: "eth_call", withBody: &body, completionHandler)
    }

    // READY
    static func eth_getTransactionCount(data: String, block: DefaultBlock, completionHandler: @escaping (_ response: SimpleRespond?, _ error: Error?) -> Void) {

        var body: JSON = JSON()
        body["params"] = [data, block.description()]
        self.invoke(method: "eth_getTransactionCount", withBody: &body, completionHandler)
    }

    // READY
    static func eth_gasPrice(completionHandler: @escaping (_ response: SimpleRespond?, _ error: Error?) -> Void) {

        var body: JSON = JSON()
        self.invoke(method: "eth_gasPrice", withBody: &body, completionHandler)
    }

    // READY
    static func eth_estimateGas(from: String?, to: String, gas: UInt?, gasPrice: UInt?, value: UInt?, data: String?, completionHandler: @escaping (_ response: SimpleRespond?, _ error: Error?) -> Void) {

        var body: JSON = JSON()
        body["params"] = [["from": from, "to": to, "gas": gas, "gasPrice": gasPrice, "value": value, "data": data]]
        removeNilParams(json: &body["params"][0])
        self.invoke(method: "eth_estimateGas", withBody: &body, completionHandler)
    }

    // READY
    static func eth_sendRawTransaction(data: String, completionHandler: @escaping (_ response: SimpleRespond?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["params"] = [data]
        self.invoke(method: "eth_sendRawTransaction", withBody: &body, completionHandler)
    }

    // READY
    static func eth_getTransactionByHash(data: String, completionHandler: @escaping (_ response: ETH_Transaction?, _ error: Error?) -> Void) {
        var body: JSON = JSON()
        body["params"] = [data]
        self.invoke(method: "eth_getTransactionByHash", withBody: &body, completionHandler)
    }
}
