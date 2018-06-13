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
    
    // submit order authorization
    var submitHash: String!
    var submitOrder: OriginalOrder!
    var signTransactions: [String: [RawTransaction]]!
    
    // cancel order authorization
    var cancelHash: String!
    var cancelOrder: CancelOrder!
    
    // convert authorization
    var convertHash: String!
    var convertTx: RawTransaction!
    
    func getSubmitOrder(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let hash = self.submitHash else { return }
        LoopringAPIRequest.notifyStatus(hash: hash, status: .received) { _, _ in }
        LoopringAPIRequest.getSignMessage(message: hash) { (data, error) in
            guard let data = data, error == nil else { return }
            self.parseSubmitOrder(from: data)
            completion(data, nil)
        }
    }
    
    func getCancelOrder(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let hash = self.cancelHash else { return }
        LoopringAPIRequest.notifyStatus(hash: hash, status: .received) { _, _ in }
        LoopringAPIRequest.getSignMessage(message: hash) { (data, error) in
            guard let data = data, error == nil else { return }
            self.parseCancelOrder(from: data, completion: completion)
        }
    }
    
    func getConvertTx(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let hash = self.convertHash else { return }
        LoopringAPIRequest.notifyStatus(hash: hash, status: .received) { _, _ in }
        LoopringAPIRequest.getSignMessage(message: hash) { (data, error) in
            guard let data = data, error == nil else { return }
            self.parseConvertTx(from: data, completion: completion)
        }
    }
    
    func parseSubmitOrder(from data: String) {
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
                    self.submitOrder = order
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
    
    func parseCancelOrder(from data: String, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        self.cancelOrder = nil
        if let data = data.data(using: .utf8) {
            let json = JSON(data)
            self.cancelOrder = CancelOrder(json: json)
            if self.cancelOrder.isValid() {
                self._authorizeCancel(completion: completion)
            }
        }
    }
    
    func parseConvertTx(from data: String, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        if let data = data.data(using: .utf8) {
            let json = JSON(data)
            self.convertTx = RawTransaction(json: json)
            self._authorizeConvert(completion: completion)
        }
    }
    
    func _signTimestamp(timestamp: String) -> SignatureData? {
        var data = Data()
        SendCurrentAppWalletDataManager.shared._keystore()
        let timestamp = timestamp.utf8
        data.append(contentsOf: Array(timestamp))
        let (signature, _) = web3swift.sign(message: data)
        return signature
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
        guard let uuid = self.loginUUID else { return }
        LoopringAPIRequest.notifyLogin(uuid: uuid, completionHandler: completion)
    }
    
    func _authorizeCancel(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address,
            let hash = self.cancelHash, let cancelOrder = self.cancelOrder else { return }
        guard owner.lowercased() == cancelOrder.owner.lowercased() else { return }
        let timestamp = cancelOrder.timestamp.description
        if let signature = _signTimestamp(timestamp: timestamp) {
            LoopringAPIRequest.cancelOrder(orderHash: cancelOrder.orderHash, owner: cancelOrder.owner, type: cancelOrder.type, cutoff: cancelOrder.cutoff, tokenS: cancelOrder.tokenS, tokenB: cancelOrder.tokenB, signature: signature, timestamp: timestamp) { (_, error) in
                guard error == nil else { completion(nil, error); return }
                LoopringAPIRequest.notifyStatus(hash: hash, status: .accept, completionHandler: completion)
            }
        }
    }
    
    func _authorizeConvert(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        guard let hash = self.convertHash, let rawTx = self.convertTx else { return }
        SendCurrentAppWalletDataManager.shared._transfer(rawTx: rawTx) { (_, error) in
            guard error == nil else { completion(nil, error); return }
            LoopringAPIRequest.notifyStatus(hash: hash, status: .accept, completionHandler: completion)
        }
    }
}
