//
//  Web3SwiftTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 4/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import web3swift
import Geth
@testable import loopr_ios

class Web3SwiftTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateAccount() {
        // Create Account
        let configuration = EthAccountConfiguration(namespace: "wallet", password: "qwerty")
        let (keystore, gethAccount) = EthAccountCoordinator.default.launch(configuration)
        
        guard keystore != nil, gethAccount != nil else {
            XCTFail("Failed to create an account.")
            return
        }

        print("Geth account")
        print(gethAccount!.getAddress().getHex())

        print("Keystore")
        print(keystore!.debugDescription)

        let gethAddress = gethAccount!.getAddress()
        XCTAssertTrue(keystore!.hasAddress(gethAddress))
        
        // Encoding Transaction
        var addressError: NSError? = nil
        let amountToTransfer = "1"
        let gethToAccountAddress: GethAddress! = GethNewAddressFromHex("0x39db95b4f60bd75846c46df165d9e854b3cf2b56", &addressError)
        guard let amount = GethBigInt.bigInt(amountToTransfer) else {
            print("Invalid amount")
            return
        }

        let transferFunction = EthFunction(name: "transfer", inputParameters: [gethToAccountAddress, amount])
        let encodedTransferFunction = web3swift.encode(transferFunction)

        // Signing Transaction
        let token = AssetDataManager.shared.getTokenBySymbol("LRC")!
        let contractAddress = GethNewAddressFromHex(token.protocol_value, nil)!
        let nonce: Int64 = 0
        let gasLimit = GethNewBigInt(SendAssetDataManager.shared.getGasLimitByType(type: "token_transfer")!)!
        let gasPrice = GethNewBigInt(20000000000)!
        
        let signedTransaction = web3swift.sign(address: contractAddress, encodedFunctionData: encodedTransferFunction, nonce: nonce, gasLimit: gasLimit, gasPrice: gasPrice)
        
        let expectation = XCTestExpectation()
        do {
            if let signedTransactionData = try signedTransaction?.encodeRLP() {
                let signedTransactionDataHexString = "0x"+signedTransactionData.hexString
                
                // Send Transaction
                SendAssetDataManager.shared.sendTransactionToServer(signedTransactionDataHexString) { (txHash, error) in
                    guard error == nil && txHash != nil else {
                        print("Failed to get valid response from server: \(error!)")
                        
                        // Expected error.
                        XCTAssertEqual("Optional(Error Domain=eth_sendRawTransaction Code=0 \"(null)\" UserInfo={code=-32000, message=insufficient funds for gas * price + value})", error.debugDescription)
                        expectation.fulfill()
                        return
                    }
                    print("Result of transfer is \(txHash!)")
                    expectation.fulfill()
                }
            }
        } catch {
            print("Failed in encoding transaction ")
        }

        wait(for: [expectation], timeout: 10.0)
    }

}
