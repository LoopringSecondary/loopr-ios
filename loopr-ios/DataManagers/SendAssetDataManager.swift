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
    
    private init() {
        self.nonce = 0
        self.wethAddress = nil
        self.protocolAddress = nil
        self.getNonceFromServer()
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
    
    // The API request teth_getTransactionCount is slow. Please be patient. It takes 3-20 seconds.
    // TODO: we can improve it.
    func getNonceFromServerSynchronous() -> Int64 {
        let start = Date()
        print("Start getNonceFromServerSynchronous")
        let semaphore = DispatchSemaphore(value: 0)
        
        if let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            EthereumAPIRequest.eth_getTransactionCount(data: address, block: BlockTag.pending, completionHandler: { (data, error) in
                print("Receive callback in getNonceFromServerSynchronous")
                guard error == nil, let data = data else {
                    return
                }
                if data.respond.isHex() {
                    self.nonce = Int64(data.respond.dropFirst(2), radix: 16)!
                } else {
                    self.nonce = Int64(data.respond)!
                }
                print("Current nounce: \(self.nonce)")
                semaphore.signal()
                let end = Date()
                let timeInterval: Double = end.timeIntervalSince(start)
                print("Time to getNonceFromServerSynchronous: \(timeInterval) seconds")
            })
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        return self.nonce
    }
    
    func getNonceFromServer() {
        let start = Date()
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
                print("Current nounce: \(self.nonce)")
                let end = Date()
                let timeInterval: Double = end.timeIntervalSince(start)
                print("Time to getNonceFromServer: \(timeInterval) seconds")
            })
        }
    }
    
    func sendTransactionToServer(_ signedTransaction: String, completion: @escaping (String?, Error?) -> Void) {
        let start = Date()
        EthereumAPIRequest.eth_sendRawTransaction(data: signedTransaction) { (data, error) in
            guard error == nil && data != nil else {
                completion(nil, error)
                return
            }
            completion(data!.respond, nil)
            let end1 = Date()
            let timeInterval1: Double = end1.timeIntervalSince(start)
            print("Time to sendTransactionToServer: \(timeInterval1) seconds")
        }
    }
    
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
        
        gethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: wallet!.getPassword())
    
        print("current address: \(gethAccount!.getAddress().getHex())")
        let end = Date()
        let timeInterval: Double = end.timeIntervalSince(start)
        print("Time to _keystore: \(timeInterval) seconds")
    }
    
    // convert weth -> eth
    func _withDraw(amount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "withdraw", inputParameters: [amount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "withdraw")!
        _transfer(data: data, address: wethAddress!, amount: GethBigInt(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // convert eth -> weth
    func _deposit(amount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "deposit", inputParameters: [])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "deposit")!
        _transfer(data: data, address: wethAddress!, amount: amount, gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // contractAddress: token address, delegateAddress: loorping delegate address
    func _approve(tokenAddress: GethAddress, delegateAddress: GethAddress, tokenAmount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "approve", inputParameters: [delegateAddress, tokenAmount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "approve")!
        // amount must be 0 for ERC20 tokens.
        _transfer(data: data, address: tokenAddress, amount: GethBigInt.init(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
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
        
        var value = GethBigInt.generateBigInt(valueInEther: order.amountSell, symbol: order.tokenSell)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.generateBigInt(valueInEther: order.amountBuy, symbol: order.tokenBuy)!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(order.validSince)
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.init(order.validUntil)
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        value = GethBigInt.generateBigInt(valueInEther: order.lrcFee, symbol: "LRC")!
        data.append(contentsOf: try! EthTypeEncoder.default.encode(value).bytes)
        
        if order.buyNoMoreThanAmountB {
            value = GethBigInt.generateBigInt(valueInEther: order.amountBuy, symbol: order.tokenBuy)!
        } else {
            value = GethBigInt.generateBigInt(valueInEther: order.amountSell, symbol: order.tokenSell)!
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
    
    func _cancelOrder(order: OriginalOrder, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let data = _encodeOrder(order: order)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "cancelOrder")!

        _transfer(data: data, address: protocolAddress!, amount: GethBigInt.init(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _cancelAllOrders(timestamp: GethBigInt/* TODO:check here*/, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "cancelAllOrders", inputParameters: [timestamp])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "cancelAllOrders")!
        _transfer(data: data, address: protocolAddress!, amount: GethBigInt.init(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _cancelOrdersByTokenPair(timestamp: GethBigInt, tokenA: GethAddress, tokenB: GethAddress, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let transferFunction = EthFunction(name: "cancelAllOrdersByTradingPair", inputParameters: [tokenA, tokenB, timestamp])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "cancelAllOrdersByTradingPair")!
        _transfer(data: data, address: protocolAddress!, amount: GethBigInt.init(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // transfer eth
    func _transferETH(amount: GethBigInt, gasPrice: GethBigInt, toAddress: GethAddress, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        let data = "0x".data(using: .utf8)!
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "eth_transfer")!
        _transfer(data: data, address: toAddress, amount: amount, gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // transfer tokens including weth
    func _transferToken(contractAddress: GethAddress, toAddress: GethAddress, tokenAmount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return
        }
        // Transfer function
        let transferFunction = EthFunction(name: "transfer", inputParameters: [toAddress, tokenAmount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = GasDataManager.shared.getGasLimitByType(by: "token_transfer")!
        // amount must be 0 for ERC20 tokens.
        _transfer(data: data, address: contractAddress, amount: GethBigInt.init(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _transfer(data: Data, address: GethAddress, amount: GethBigInt, gasPrice: GethBigInt, gasLimit: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        _keystore()
        var userInfo: [String: Any] = [:]
        do {
            // Async call. Of course we need to clean the following code.
            // Copy getNonceFromServer
            let start = Date()
            if let publicAddress = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
                EthereumAPIRequest.eth_getTransactionCount(data: publicAddress, block: BlockTag.pending, completionHandler: { (getTransactionCountData, error) in
                    guard error == nil, let getTransactionCountData = getTransactionCountData else {
                        return
                    }
                    if getTransactionCountData.respond.isHex() {
                        self.nonce = Int64(getTransactionCountData.respond.dropFirst(2), radix: 16)!
                    } else {
                        self.nonce = Int64(getTransactionCountData.respond)!
                    }
                    print("Current nounce: \(self.nonce)")
                    let end1 = Date()
                    let timeInterval1: Double = end1.timeIntervalSince(start)
                    print("Time to getNonceFromServer in _transfer: \(timeInterval1) seconds")
                    
                    // Sign Transaction
                    do {
                        let signedTransaction = web3swift.sign(address: address, encodedFunctionData: data, nonce: self.nonce, amount: amount, gasLimit: gasLimit, gasPrice: gasPrice, password: CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.getPassword())
                        if let signedTransactionData = try signedTransaction?.encodeRLP() {
                            self.sendTransactionToServer("0x" + signedTransactionData.hexString, completion: completion)
                        } else {
                            userInfo["message"] = NSLocalizedString("Failed to sign/encode", comment: "")
                            let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
                            completion(nil, error)
                        }
                        let end2 = Date()
                        let timeInterval2: Double = end2.timeIntervalSince(end1)
                        print("Time to sign transactinon in _transfer: \(timeInterval2) seconds")
                    } catch {
                        userInfo["message"] = NSLocalizedString("Failed to encode transaction", comment: "")
                        let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
                        completion(nil, error)
                    }
                })
            }
        }
    }
}
