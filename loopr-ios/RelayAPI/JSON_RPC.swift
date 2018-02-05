//
//  JSON_RPC.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

public class JSON_RPC {
    
    static func getBalance(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getBalance"
        body["params"] = [["owner": "0x847983c3a34afa192cfee860698584c030f4c9db1"]]
        body["contractVersion"] = "v1.0"
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
    // TODO: Add a closure
    static func getOrder(completionHandler: @escaping CompletionHandler) {
        var body: JSON = JSON()
        body["method"] = "loopring_getOrders"
        body["params"] = [["ringHash": nil, "pageIndex": 0, "pageSize": 20]]
        body["contractVersion"] = "v1.0"
        body["id"] = "1a715e2557abc0bd"
        
        Request.send(body: body) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            completionHandler(data, response, error)
        }
    }
    
}
