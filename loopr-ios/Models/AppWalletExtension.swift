//
//  AppWalletExtension.swift
//  loopr-ios
//
//  Created by xiaoruby on 9/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Crashlytics

extension AppWallet {

    func getNonceFromEthereum(completionHandler: @escaping () -> Void) {
        let start = Date()
        EthereumAPIRequest.eth_getTransactionCount(data: address, block: BlockTag.pending, completionHandler: { (data, error) in
            guard error == nil, let data = data else {
                Answers.logCustomEvent(withName: "API Request Error v1",
                                       customAttributes: [
                                        "type": "getNonceFromEthereum"])
                completionHandler()
                return
            }
            var nonce: Int64
            if data.respond.isHex() {
                nonce = Int64(data.respond.dropFirst(2), radix: 16)!
            } else {
                nonce = Int64(data.respond)!
            }
            if nonce > self.nonce {
                self.nonce = nonce
            }
            print("^^^^^^^^^^^^^^^^^^^^^^self.nonce = \(self.nonce)")
            let end = Date()
            let timeInterval: Double = end.timeIntervalSince(start)
            print("Time to getNonceFromEthereum: \(timeInterval) seconds")
            
            // TODO: Answers may not support this feature. 
            Answers.logCustomEvent(withName: "API Performance: getNonceFromEthereum v1",
                                   customAttributes: [
                                    "success": "true",
                                    "timing (ms)": Int(timeInterval*1000.0)])
            print(Int(timeInterval*1000.0))

            completionHandler()
        })
    }
    
    func incrementNonce() {
        self.nonce += 1
    }
    
    func completeRawTx(_ rawTx: inout RawTransaction) {
        if self.nonce < rawTx.nonce {
            self.nonce = rawTx.nonce
        }
        rawTx.nonce = self.nonce
    }

}
