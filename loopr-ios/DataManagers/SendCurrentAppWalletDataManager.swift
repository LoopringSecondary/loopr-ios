//
//  SendCurrentAppWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

class SendCurrentAppWalletDataManager {
    
    static let shared = SendCurrentAppWalletDataManager()
    
    // sending token in send controller
    open var token: Token?
    
    private var wethAddress: GethAddress?
    private var protocolAddress: GethAddress?
    private var userInfo: [String: Any] = [:]
    
    private init() {
        self.token = nil
        self.wethAddress = nil
        self.protocolAddress = nil
        self.getWethAddress()
        self.getProtocolAddress()
    }
    
    func getWethAddress() {
        var address = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
        if let weth = TokenDataManager.shared.getTokenBySymbol("WETH") {
            address = weth.protocol_value
        }
        var error: NSError?
        self.wethAddress = GethNewAddressFromHex(address, &error)
    }

    func getProtocolAddress() {
        var error: NSError?
        self.protocolAddress = GethNewAddressFromHex(RelayAPIConfiguration.protocolAddress, &error)
    }

    func sendTransactionToServer(signedTransaction: String, completion: @escaping (String?, Error?) -> Void) {
        EthereumAPIRequest.eth_sendRawTransaction(data: signedTransaction) { (data, error) in
            guard error == nil && data != nil else {
                completion(nil, error)
                return
            }
            CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.incrementNonce()
            completion(data!.respond, nil)
        }
    }
    
    // TODO: Move this function to 
    func _keystore() {
        let start = Date()
        let wallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
        var gethAccount: GethAccount?
    
        // Get Keystore string value
        let keystoreStringValue: String = wallet!.getKeystore()
        
        // Create key directory
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreSendAssetViewController")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletSendAssetViewController")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory)
        
        // Save the keystore string value to keyDirectory
        let fileURL = keyDirectory.appendingPathComponent("key.json")
        try! keystoreStringValue.write(to: fileURL, atomically: false, encoding: .utf8)
        
        print(keyDirectory.absoluteString)
        let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
        
        let gethKeystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
        
        gethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: wallet!.getKeystorePassword())
    
        print("keystoreing address: \(gethAccount!.getAddress().getHex())")
        
        guard gethAccount!.getAddress().getHex() == wallet?.address else {
            print("keystoreStringValue: \(keystoreStringValue)")
            preconditionFailure("Fail to use keystore to get the keystoreing address.")
        }

        let end = Date()
        let timeInterval: Double = end.timeIntervalSince(start)
        print("Time to _keystore: \(timeInterval) seconds")
    }
    
    // convert weth -> eth
    func _withDraw(amount: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "withdraw", inputParameters: [amount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimit(by: "withdraw")!
        _transfer(data: data, address: wethAddress!, amount: GethBigInt(0), gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // convert eth -> weth
    func _deposit(amount: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "deposit", inputParameters: [])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimit(by: "deposit")!
        _transfer(data: data, address: wethAddress!, amount: amount, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _approve(tokenAddress: GethAddress, delegateAddress: GethAddress, tokenAmount: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "approve", inputParameters: [delegateAddress, tokenAmount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimit(by: "approve")!
        // amount must be 0 for ERC20 tokens.
        _transfer(data: data, address: tokenAddress, amount: GethBigInt.init(0), gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _cancelOrder(order: OriginalOrder, completion: @escaping (String?, Error?) -> Void) {
        if let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            let timestamp = Int(Date().timeIntervalSince1970).description
            if let signature = AuthorizeDataManager.shared._signTimestamp(timestamp: timestamp) {
                LoopringAPIRequest.cancelOrder(owner: owner, type: .hash, orderHash: order.hash, cutoff: nil, tokenS: nil, tokenB: nil, signature: signature, timestamp: timestamp, completionHandler: completion)
            }
        }
    }
    
    func _cancelAllOrders(completion: @escaping (String?, Error?) -> Void) {
        if let owner = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            let cutoff = Int64(Date().timeIntervalSince1970)
            let timestamp = cutoff.description
            if let signature = AuthorizeDataManager.shared._signTimestamp(timestamp: timestamp) {
                LoopringAPIRequest.cancelOrder(owner: owner, type: .time, orderHash: nil, cutoff: cutoff, tokenS: nil, tokenB: nil, signature: signature, timestamp: timestamp, completionHandler: completion)
            }
        }
    }
    
    func _cancelOrdersByTokenPair(timestamp: GethBigInt, tokenA: GethAddress, tokenB: GethAddress, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "cancelAllOrdersByTradingPair", inputParameters: [tokenA, tokenB, timestamp])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimit(by: "cancelAllOrdersByTradingPair")!
        _transfer(data: data, address: protocolAddress!, amount: GethBigInt.init(0), gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // transfer eth
    func _transferETH(amount: GethBigInt, toAddress: GethAddress, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let data = "0x".data(using: .utf8)!
        let gasLimit: Int64 = GasDataManager.shared.getGasLimit(by: "eth_transfer")!
        _transfer(data: data, address: toAddress, amount: amount, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // transfer tokens including weth
    func _transferToken(contractAddress: GethAddress, toAddress: GethAddress, tokenAmount: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "transfer", inputParameters: [toAddress, tokenAmount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimit(by: "token_transfer")!
        // amount must be 0 for ERC20 tokens.
        _transfer(data: data, address: contractAddress, amount: GethBigInt.init(0), gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _sign(data: Data, address: GethAddress, amount: GethBigInt, gasLimit: GethBigInt, completion: @escaping (String?, Error?) -> Void) -> String? {
        _keystore()
        let gasPrice = GasDataManager.shared.getGasPriceInWei()
        let password = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.getKeystorePassword()
        let nonce = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.nonce
        let signedTransaction = web3swift.sign(address: address, encodedFunctionData: data, nonce: nonce, amount: amount, gasLimit: gasLimit, gasPrice: gasPrice, password: password)
        do {
            if let signedTransactionData = try signedTransaction?.encodeRLP() {
                return "0x" + signedTransactionData.hexString
            }
        } catch {
            userInfo["message"] = LocalizedString("Failed to sign/encode transaction", comment: "")
            let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
            completion(nil, error)
        }
        return nil
    }
    
    func _transfer(data: Data, address: GethAddress, amount: GethBigInt, gasLimit: GethBigInt, completion: @escaping (_ txHash: String?, _ error: Error?) -> Void) {
        let nonce = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.nonce
        let tx = RawTransaction(data: data, to: address, value: amount, gasLimit: gasLimit, gasPrice: GasDataManager.shared.getGasPriceInWei(), nonce: nonce)
        let from = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        if let signedTransaction = _sign(data: data, address: address, amount: amount, gasLimit: gasLimit, completion: completion) {
            self.sendTransactionToServer(signedTransaction: signedTransaction, completion: { (txHash, error) in
                if txHash != nil && error == nil {
                    LoopringAPIRequest.notifyTransactionSubmitted(txHash: txHash!, rawTx: tx, from: from, completionHandler: completion)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    func _sign(rawTx: RawTransaction, completion: @escaping (_ txHash: String?, _ error: Error?) -> Void) -> String? {
        _keystore()
        let password = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.getKeystorePassword()
        if let data = Data(hexString: rawTx.data),
            let amount = GethBigInt.generate(rawTx.value),
            let address = GethAddress.init(fromHex: rawTx.to),
            let gasPrice = rawTx.gasPrice.hexToInteger,
            let gasLimit = rawTx.gasLimit.hexToInteger {
            let signedTransaction = web3swift.sign(address: address, encodedFunctionData: data, nonce: rawTx.nonce, amount: amount, gasLimit: GethBigInt(Int64(gasLimit)), gasPrice: GethBigInt(Int64(gasPrice)), password: password)
            do {
                if let signedTransactionData = try signedTransaction?.encodeRLP() {
                    return "0x" + signedTransactionData.hexString
                }
            } catch {
                userInfo["message"] = LocalizedString("Failed to sign/encode transaction", comment: "")
                let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
                completion(nil, error)
            }
        }
        return nil
    }
    
    func _transfer(rawTx: RawTransaction, completion: @escaping (_ txHash: String?, _ error: Error?) -> Void) {
        var rawTransaction = rawTx
        CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.completeRawTx(&rawTransaction)
        let from = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        if let signedTransaction = _sign(rawTx: rawTransaction, completion: completion) {
            self.sendTransactionToServer(signedTransaction: signedTransaction, completion: { (txHash, error) in
                if txHash != nil && error == nil {
                    LoopringAPIRequest.notifyTransactionSubmitted(txHash: txHash!, rawTx: rawTransaction, from: from, completionHandler: completion)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    func transferOnce(rawTx: RawTransaction, completion: @escaping (_ txHash: String?, _ error: Error?) -> Void) {
        _transfer(rawTx: rawTx, completion: completion)
    }
    
    func transferTwice(rawTxs: [RawTransaction], completion: @escaping (_ txHash: String?, _ error: Error?) -> Void) {
        _transfer(rawTx: rawTxs[0]) { (_, error) in
            guard error == nil else { completion(nil, error!); return }
            self._transfer(rawTx: rawTxs[1], completion: completion)
        }
    }
}
