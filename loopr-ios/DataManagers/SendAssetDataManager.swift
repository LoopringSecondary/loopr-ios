//
//  SendCurrentAppWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

struct GasLimit {
    let type: String
    let gasLimit: Int64
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.gasLimit = json["gasLimit"].int64Value
    }
}

class SendCurrentAppWalletDataManager {
    
    static let shared = SendCurrentAppWalletDataManager()
    
    var amount: Double
    private var maxAmount: Double // ??
    private var gasLimits: [GasLimit]
    private var nonce: Int64
    
    private init() {
        self.amount = 0.0
        self.maxAmount = 0.0
        self.gasLimits = []
        self.nonce = 0
        self.loadGasLimitsFromJson()
        self.getNonceFromServer()
    }
    
    func getNonce() -> Int64 {
        getNonceFromServer()
        return self.nonce
    }
    
    func getGasLimits() -> [GasLimit] {
        return gasLimits
    }
    
    // TODO: Why we need to load gas_limit from a json file instead of writing as code.
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
        var gasLimit: Int64? = nil
        for case let gas in gasLimits where gas.type.lowercased() == type.lowercased() {
            gasLimit = gas.gasLimit
            break
        }
        return gasLimit
    }
    
    func getNonceFromServer() {
        if let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            EthereumAPIRequest.eth_getTransactionCount(data: address, block: BlockTag.pending, completionHandler: { (data, error) in
                guard error == nil, let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    if data.respond.isHex() {
                        self.nonce = Int64(data.respond.dropFirst(2), radix: 16)!
                    } else {
                        self.nonce = Int64(data.respond)!
                    }
                }
            })
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
    
    func _transfer(method: String, contractAddress: GethAddress, toAddress: GethAddress, amount: GethBigInt, gasType: String, gasPrice: Int64, completion: @escaping (String?, Error?) -> Void) {
        // TODO: improve the following code.
        let currentAppWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
        guard currentAppWallet != nil else {
            return
        }
        
        // Get Keystore string value
        let keystoreStringValue: String = currentAppWallet!.getKeystore().description
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
        
        // let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        print(keyDirectory.absoluteString)
        let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
        let gethKeystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
        let gethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: currentAppWallet!.password)
        print(gethAccount!.getAddress().getHex())
        
        // Transfer function
        let transferFunction = EthFunction(name: method, inputParameters: [toAddress, amount])
        let encodedTransferFunction = web3swift.encode(transferFunction) // ok here
        
        do {
            let nonce: Int64 = getNonce()
            let gasLimit: Int64 = getGasLimitByType(type: gasType)!
            let signedTransaction = web3swift.sign(address: contractAddress, encodedFunctionData: encodedTransferFunction, nonce: nonce, gasLimit: GethNewBigInt(gasLimit), gasPrice: GethNewBigInt(gasPrice), password: currentAppWallet!.password)
            if let signedTransactionData = try signedTransaction?.encodeRLP() { // also ok here
                sendTransactionToServer("0x" + signedTransactionData.hexString, completion: completion)
            } else {
                print("Failed to sign/encode")
            }
        } catch {
            print("Failed in encoding transaction ")
        }
    }
}
