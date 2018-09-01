//
//  Web3SwiftTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 4/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
@testable import Geth

class Web3SwiftTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGethKeyStoreInit() {
        // Create Account
        let configuration = EthAccountConfiguration(namespace: "wallet", password: "qwerty")
        
        let (keystore, gethAccount, keystoreFilePath) = EthAccountCoordinator.default.launch(configuration)
        XCTAssertNotNil(keystore)
        XCTAssertNotNil(gethAccount)
        
        print(keystoreFilePath)
        print(gethAccount?.getAddress().getHex())
        
        do {
            try keystore?.unlock(gethAccount!, passphrase: "qwerty")
        } catch {
            print("Failed to sign transaction")
        }

        let keystore2 = GethKeyStore.init(keystoreFilePath, scryptN: GethLightScryptN, scryptP: GethLightScryptP)
        XCTAssertNotNil(keystore2)
        do {
            try keystore2?.unlock(gethAccount!, passphrase: "qwerty")
            let accounts = keystore2?.getAccounts()!
            print(accounts)
            
        } catch {
            print("Failed to sign transaction")
        }
    }
    
    // testKeystore.json and password 123456 will unlock the address 0x7C0C5B3C78f04f4ca42EBFb3cb4EA57D5e549392
    func _testImportWalletUsingKeystore() {
        let currentFile = #file
        let keydir = currentFile.replacingOccurrences(of: "Web3SwiftTests.swift", with: "", options: .regularExpression)
        let keystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
        let gethAccount = EthAccountCoordinator.default.launch(keystore: keystore, password: "123456")
        print(gethAccount!.getAddress().getHex())
        XCTAssertEqual(gethAccount?.getAddress().getHex()!, "0x7C0C5B3C78f04f4ca42EBFb3cb4EA57D5e549392")
    }

    func testCreateAccount() {
        // Create Account
        let configuration = EthAccountConfiguration(namespace: "wallet", password: "qwerty")
        let (keystore, gethAccount) = EthAccountCoordinator.default.launch(configuration)
        
        /*
        let url = Bundle(for: type(of: self)).url(forResource: "key", withExtension: "json")!
        print(url.absoluteString)
        let keystore2 = GethKeyStore.init(url.absoluteString, scryptN: GethLightScryptN, scryptP: GethLightScryptP)
        */
        // try! keystore?.importKey(data, passphrase: "123456", newPassphrase: "123456")
        
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
        let amountToTransfer: Double = 1
        let gethToAccountAddress: GethAddress! = GethNewAddressFromHex("0x8311804426a24495bd4306daf5f595a443a52e32", &addressError)
        guard let amount = GethBigInt.generate(amountToTransfer)  else {
            print("Invalid amount")
            return
        }

        let transferFunction = EthFunction(name: "transfer", inputParameters: [gethToAccountAddress, amount])
        let encodedTransferFunction = web3swift.encode(transferFunction)

        // Signing Transaction
        let token = TokenDataManager.shared.getTokenBySymbol("LRC")!
        let contractAddress = GethNewAddressFromHex(token.protocol_value, nil)!
        let nonce: Int64 = 0
        let gasLimit = GethNewBigInt(GasDataManager.shared.getGasLimit(by: "token_transfer")!)!
        let gasPrice = GethNewBigInt(20000000000)!
        
        /*
        let signedTransaction = web3swift.sign(address: contractAddress, encodedFunctionData: encodedTransferFunction, nonce: nonce, gasLimit: gasLimit, gasPrice: gasPrice)
        
        let expectation = XCTestExpectation()
        do {
            if let signedTransactionData = try signedTransaction?.encodeRLP() {
                let signedTransactionDataHexString = "0x"+signedTransactionData.hexString
                
                // Send Transaction
                SendCurrentAppWalletDataManager.shared.sendTransactionToServer(signedTransactionDataHexString) { (txHash, error) in
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
        */
    }

}
