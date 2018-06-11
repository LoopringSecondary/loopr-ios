//
//  AuthorizeDataManager.swift
//  loopr-ios
//
//  Created by kenshin on 2018/6/11.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import Foundation

class AuthorizeDataManager {
    
    static let shared = AuthorizeDataManager()
    
    // login authorization
    var loginUUID: String!
    
    // order authorization
    var signHash: String!
    var signOrder: OriginalOrder!
    var signTransactions: [String: [RawTransaction]]!
    
    func getOrder(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let hash = self.signHash else { return }
        LoopringAPIRequest.updateSignMessage(hash: hash, status: .received) { _, _ in }
        LoopringAPIRequest.getSignMessage(message: hash) { (data, error) in
            guard let data = data, error == nil else { return }
            self.parse(from: data)
            completion(data, nil)
        }
    }
    
    func parse(from data: String) {
        self.signTransactions = [:]
        if let data = data.data(using: .utf8) {
            for subJson in JSON(data).arrayValue {
                if subJson["type"] == "order" {
                    var order = OriginalOrder(json: subJson["data"])
                    let side = subJson["side"].stringValue
                    let market = subJson["market"].stringValue
                    order.side = side
                    order.market = market
                    PlaceOrderDataManager.shared.completeOrder(&order)
                    self.signOrder = order
                } else if subJson["type"] == "tx" {
                    let tx = SignRawTransaction(json: subJson)
                    if self.signTransactions[tx.token] == nil {
                        self.signTransactions[tx.token] = []
                    }
                    self.signTransactions[tx.token]!.insert(tx.rawTx, at: tx.index)
                }
            }
        }
    }
    
    func _authorizeOrder(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard self.signTransactions.count > 0 else {
            completion(nil, nil)
            return
        }
        for (_, rawTxs) in self.signTransactions {
            if rawTxs.count == 1 {
                SendCurrentAppWalletDataManager.shared.transferOnce(rawTx: rawTxs[0], completion: completion)
            } else if rawTxs.count == 2 {
                SendCurrentAppWalletDataManager.shared.transferTwice(rawTxs: rawTxs, completion: completion)
            }
        }
    }
    
    func _authorizeLogin(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address,
            let uuid = self.loginUUID else { return }
        var data = Data()
        SendCurrentAppWalletDataManager.shared._keystore()
        let timestamp = Int(Date().timeIntervalSince1970).description
        data.append(contentsOf: timestamp.hexBytes)
        if case (let signature?, _) = web3swift.sign(message: data) {
            LoopringAPIRequest.updateScanLogin(owner: owner, uuid: uuid, signature: signature, timestamp: timestamp, completionHandler: completion)
        }
    }
}
