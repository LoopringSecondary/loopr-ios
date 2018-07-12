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
    
    private var nonce: Int64
    private var wethAddress: GethAddress?
    private var protocolAddress: GethAddress?
    private var userInfo: [String: Any] = [:]
    
    private init() {
        self.nonce = 0
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
        var error: NSError? = nil
        self.wethAddress = GethNewAddressFromHex(address, &error)
    }

    func getProtocolAddress() {
        var error: NSError? = nil
        self.protocolAddress = GethNewAddressFromHex(RelayAPIConfiguration.protocolAddress, &error)
    }
    
    func incrementNonce() {
        self.nonce += 1
    }

    func getNonceFromRelay() {
        print("Start getNonceFromRelay")
        let semaphore = DispatchSemaphore(value: 0)
        if let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            LoopringAPIRequest.getNonce(owner: address) { (result, error) in
                guard error == nil, let data = result else {
                    return
                }
                if let value = Int64(data), self.nonce > value {
                    self.nonce = value
                }
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }

    func getNonceFromEthereum() {
        if let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            EthereumAPIRequest.eth_getTransactionCount(data: address, block: BlockTag.pending, completionHandler: { (data, error) in
                guard error == nil, let data = data else {
                    return
                }
                if data.respond.isHex() {
                    self.nonce = Int64(data.respond.dropFirst(2), radix: 16)!
                } else {
                    self.nonce = Int64(data.respond)!
                }
            })
        }
    }
    
    func completeRawTx(_ rawTx: inout RawTransaction) {
        getNonceFromRelay()
        if self.nonce < rawTx.nonce {
            self.nonce = rawTx.nonce
        }
        rawTx.nonce = self.nonce
    }
    
    func sendTransactionToServer(signedTransaction: String, completion: @escaping (String?, Error?) -> Void) {
        let start = Date()
        EthereumAPIRequest.eth_sendRawTransaction(data: signedTransaction) { (data, error) in
            guard error == nil && data != nil else {
                print(error!)
                completion(nil, error)
                return
            }
            completion(data!.respond, nil)
            let end1 = Date()
            let timeInterval1: Double = end1.timeIntervalSince(start)
            print("Time to sendTransactionToServer: \(timeInterval1) seconds")
        }
    }
    
    // TODO: Move this function to 
    func _keystore() {
        let start = Date()
        let wallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
        var gethAccount: GethAccount?
    
        // Get Keystore string value
        let keystoreStringValue: String = wallet!.getKeystore()
        print(keystoreStringValue)
        
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
    
        print("current address: \(gethAccount!.getAddress().getHex())")
        
        guard gethAccount!.getAddress().getHex() == wallet?.address else {
            print("keystoreStringValue: \(keystoreStringValue)")
            preconditionFailure("Fail to use keystore to get the current wallet address.")
        }
        
        print("################### keystore ###################")
        print(wallet!.getKeystore())
        print("################### end ###################")
        
        print("################### keystore password ###################")
        print(wallet!.getKeystorePassword())
        print("################### end ###################")

        let end = Date()
        let timeInterval: Double = end.timeIntervalSince(start)
        print("Time to _keystore: \(timeInterval) seconds")
    }

    func _encodeOrder(order: OriginalOrder) -> Data {
        var data: Data = Data()
        var error: NSError? = nil
        var address: GethAddress
        address = GethNewAddressFromHex(order.address, &error)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(address).bytes)
        let tokens = TokenDataManager.shared.getAddress(by: order.tokenSell)
        address = GethNewAddressFromHex(tokens, &error)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(address).bytes)
        let tokenb = TokenDataManager.shared.getAddress(by: order.tokenBuy)
        address = GethNewAddressFromHex(tokenb, &error)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(address).bytes)
        address = GethNewAddressFromHex(order.walletAddress, &error)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(address).bytes)
        address = GethNewAddressFromHex(order.authAddr, &error)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(address).bytes)
        
        var value = GethBigInt.generate(valueInEther: order.amountSell, symbol: order.tokenSell)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.generate(valueInEther: order.amountBuy, symbol: order.tokenBuy)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(order.validSince)
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(order.validUntil)
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.generate(valueInEther: order.lrcFee, symbol: "LRC")!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        
        if order.buyNoMoreThanAmountB {
            value = GethBigInt.generate(valueInEther: order.amountBuy, symbol: order.tokenBuy)!
        } else {
            value = GethBigInt.generate(valueInEther: order.amountSell, symbol: order.tokenSell)!
        }
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(order.buyNoMoreThanAmountB ? 1 : 0)
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(Int64(order.marginSplitPercentage))
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(Int64(order.v))
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        data.append(contentsOf: order.r.hexBytes)
        data.append(contentsOf: order.s.hexBytes)
        
        data = Data("0x8c59f7ca".hexBytes) + data
        return data
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
    
    // contractAddress: token address, delegateAddress: loorping delegate address
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
    
    // tokena: contract addr
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
        let signedTransaction = web3swift.sign(address: address, encodedFunctionData: data, nonce: self.nonce, amount: amount, gasLimit: gasLimit, gasPrice: gasPrice, password: password)
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
        self.getNonceFromRelay()
        let tx = RawTransaction(data: data, to: address, value: amount, gasLimit: gasLimit, gasPrice: GasDataManager.shared.getGasPriceInWei(), nonce: self.nonce)
        let from = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        if let signedTransaction = _sign(data: data, address: address, amount: amount, gasLimit: gasLimit, completion: completion) {
            self.sendTransactionToServer(signedTransaction: signedTransaction, completion: { (txHash, error) in
                if txHash != nil && error == nil {
                    LoopringAPIRequest.notifyTransactionSubmitted(txHash: txHash!, rawTx: tx, from: from, completionHandler: completion)
                } else {
                    completion(nil, error)
                }
                self.nonce += 1
            })
        }
    }
    
    func _sign(rawTx: RawTransaction, completion: @escaping (_ txHash: String?, _ error: Error?) -> Void) -> String? {
        _keystore()
        let password = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.getKeystorePassword()
        if let data = Data(hexString: rawTx.data),
            let amount = GethBigInt.generate(rawTx.value),
            let address = GethAddress.init(fromHex: rawTx.to),
            let gasPrice = rawTx.gasPrice.integer,
            let gasLimit = rawTx.gasLimit.integer {
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
        completeRawTx(&rawTransaction)
        let from = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        if let signedTransaction = _sign(rawTx: rawTransaction, completion: completion) {
            self.sendTransactionToServer(signedTransaction: signedTransaction, completion: { (txHash, error) in
                if txHash != nil && error == nil {
                    LoopringAPIRequest.notifyTransactionSubmitted(txHash: txHash!, rawTx: rawTransaction, from: from, completionHandler: completion)
                } else {
                    completion(nil, error)
                }
                self.nonce += 1
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
