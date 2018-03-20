//
//  SendAssetDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SwiftyJSON

struct GasLimit {
    let type: String
    let gasLimit: Int64
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.gasLimit = json["gasLimit"].int64Value
    }
}

class SendAssetDataManager {
    
    static let shared = SendAssetDataManager()
    
    var amount: Double
    
    // TODO: Use mock data
    private var maxAmount: Double = 96.3236
    private var gasLimits: [GasLimit] = []
    
    private init() {
        amount = 0.0
    }
    
    func getGasLimits() -> [GasLimit] {
        return gasLimits
    }
    
    // load
    func loadGasLimitsFromJson() {
        if let path = Bundle.main.path(forResource: "gas_limit", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let json = JSON(parseJSON: jsonString!)
            for subJson in json.arrayValue {
                let token = GasLimit(json: subJson)
                gasLimits.append(token)
            }
        }
    }

    func getGasLimitByType(type: String) -> Int64? {
        var result: Int64? = nil
        for case let gas in gasLimits where gas.type.lowercased() == type.lowercased() {
            result = gas.gasLimit
            break
        }
        return result
    }
    
    func getNonceFromServer(completion: @escaping (Int64?, Error?) -> Void) {
        if let address = AppWalletDataManager.shared.getCurrentAppWallet()?.address {
            EthereumAPIRequest.eth_getTransactionCount(data: address, block: BlockTag.pending, completionHandler: { (data, error) in
                guard error == nil && data != nil else {
                    completion(nil, error)
                    return
                }
                completion(Int64(data!.respond), nil)
            })
        } else {
            let error = NSError(domain: "getNonce", code: 0, userInfo: ["reason": "wallet address is nil"])
            completion(nil, error)
        }
    }
    
    func sendTransactionToServer(_ signedTransaction: String, completion: @escaping (String?, Error?) -> Void) {
        EthereumAPIRequest.eth_sendRawTransaction(data: signedTransaction) { (data, error) in
            guard error == nil && data != nil else {
                completion(nil, error)
                return
            }
            completion(data!.respond, nil)
        }
    }
    
}
