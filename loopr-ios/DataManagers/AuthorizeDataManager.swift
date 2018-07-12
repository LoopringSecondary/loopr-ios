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
    var convertOwner: String!
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
            self.convertTx = RawTransaction(json: json["tx"])
            self.convertOwner = json["owner"].stringValue
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
        let tokens = Array(signTransactions.keys)
        if self.signTransactions.count == 0 {
            completion(nil, nil)
            return
        } else if self.signTransactions.count == 1 {
            if let rawTxs = self.signTransactions[tokens[0]] {
                if rawTxs.count == 1 {
                    SendCurrentAppWalletDataManager.shared.transferOnce(rawTx: rawTxs[0], completion: completion)
                } else if rawTxs.count == 2 {
                    SendCurrentAppWalletDataManager.shared.transferTwice(rawTxs: rawTxs, completion: completion)
                }
            }
        } else if self.signTransactions.count == 2 {
            if let rawTxsA = self.signTransactions[tokens[0]], let rawTxsB = self.signTransactions[tokens[1]] {
                if rawTxsA.count == 1 {
                    SendCurrentAppWalletDataManager.shared.transferOnce(rawTx: rawTxsA[0]) { (txHash, error) in
                        guard error == nil && txHash != nil else { completion(nil, error!); return }
                        if rawTxsB.count == 1 {
                            SendCurrentAppWalletDataManager.shared.transferOnce(rawTx: rawTxsB[0], completion: completion)
                        } else if rawTxsB.count == 2 {
                            SendCurrentAppWalletDataManager.shared.transferTwice(rawTxs: rawTxsB, completion: completion)
                        }
                    }
                } else if rawTxsA.count == 2 {
                    SendCurrentAppWalletDataManager.shared.transferTwice(rawTxs: rawTxsA) { (txHash, error) in
                        guard error == nil && txHash != nil else { completion(nil, error!); return }
                        if rawTxsB.count == 1 {
                            SendCurrentAppWalletDataManager.shared.transferOnce(rawTx: rawTxsB[0], completion: completion)
                        } else if rawTxsB.count == 2 {
                            SendCurrentAppWalletDataManager.shared.transferTwice(rawTxs: rawTxsB, completion: completion)
                        }
                    }
                }
            }
        }
    }
    
    func authorizeLogin(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        let error = NSError(domain: "login", code: 0, userInfo: ["message": "error"])
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address,
            let uuid = self.loginUUID else { completion(nil, error); return }
        let timestamp = Int(Date().timeIntervalSince1970).description
        if let signature = _signTimestamp(timestamp: timestamp) {
            LoopringAPIRequest.updateScanLogin(owner: owner, uuid: uuid, signature: signature, timestamp: timestamp, completionHandler: completion)
        }
    }

    func _authorizeLogin(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            AuthenticationDataManager.shared.authenticate { (error) in
                guard error == nil else { completion(nil, error); return }
                self.authorizeLogin(completion: completion)
            }
        } else {
            self.authorizeLogin(completion: completion)
        }
    }
    
    func authorizeCancel(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        let error = NSError(domain: "cancel", code: 0, userInfo: ["message": "error"])
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address,
            let hash = self.cancelHash, let cancelOrder = self.cancelOrder else { completion(nil, error); return }
        guard owner.lowercased() == cancelOrder.owner.lowercased() else { completion(nil, error); return }
        let timestamp = cancelOrder.timestamp.description
        if let signature = _signTimestamp(timestamp: timestamp) {
            LoopringAPIRequest.cancelOrder(owner: cancelOrder.owner, type: cancelOrder.type, orderHash: cancelOrder.orderHash, cutoff: cancelOrder.cutoff, tokenS: cancelOrder.tokenS, tokenB: cancelOrder.tokenB, signature: signature, timestamp: timestamp) { (_, error) in
                guard error == nil else { completion(nil, error); return }
                LoopringAPIRequest.notifyStatus(hash: hash, status: .accept, completionHandler: completion)
            }
        }
    }
    
    func _authorizeCancel(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            AuthenticationDataManager.shared.authenticate { (error) in
                guard error == nil else { completion(nil, error); return }
                self.authorizeCancel(completion: completion)
            }
        } else {
            self.authorizeCancel(completion: completion)
        }
    }
    
    func authorizeConvert(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        let error = NSError(domain: "convert", code: 0, userInfo: ["message": "error"])
        guard let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address,
            let hash = self.convertHash, let rawTx = self.convertTx else { completion(nil, error); return }
        guard owner.lowercased() == self.convertOwner.lowercased() else { completion(nil, error); return }
        SendCurrentAppWalletDataManager.shared._transfer(rawTx: rawTx) { (_, error) in
            guard error == nil else { completion(nil, error); return }
            LoopringAPIRequest.notifyStatus(hash: hash, status: .accept, completionHandler: completion)
        }
    }
    
    func _authorizeConvert(completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        if AuthenticationDataManager.shared.getPasscodeSetting() {
            AuthenticationDataManager.shared.authenticate { (error) in
                guard error == nil else { completion(nil, error); return }
                self.authorizeConvert(completion: completion)
            }
        } else {
            self.authorizeConvert(completion: completion)
        }
    }
}
