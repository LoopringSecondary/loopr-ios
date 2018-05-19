//
//  Web3swift.swift
//  web3swift
//
//  Created by Sameer Khavanekar on 1/18/18.
//  Copyright © 2018 Radical App LLC. All rights reserved.
//

import Foundation
import Geth

let web3swift = Web3swift()

class Web3swift {

    public func encode(_ function: EthFunction) -> Data {
        return EthFunctionEncoder.default.encode(function)
    }
    
    public func sign(address: GethAddress, encodedFunctionData: Data, nonce: Int64, amount: GethBigInt, gasLimit: GethBigInt, gasPrice: GethBigInt, password: String? = nil) -> GethTransaction? {
        return EthAccountCoordinator.default.sign(address: address, encodedFunctionData: encodedFunctionData, nonce: nonce, amount: amount, gasLimit: gasLimit, gasPrice: gasPrice, password: password)
    }
    
    public func sign(message: Data) -> (SignatureData?, String?) {
        guard let defaultKeystore = EthAccountCoordinator.default.keystore, let defaultAccount = EthAccountCoordinator.default.account, let password = EthAccountCoordinator.default.defaultConfiguration.password else {
            print("Default Account not set, Please use Sign.sign instead")
            return (nil, nil)
        }
        return Sign.sign(message: message, keystore: defaultKeystore, account: defaultAccount, passphrase: password)
    }

}
