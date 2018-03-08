//
//  eth_JSON_RPC.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 2/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
import SwiftyJSON

class eth_JSON_RPCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCall() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_call(from: nil, to: "0x98C9D14a894d19a38744d41CD016D89Cf9699a51", gas: nil, gasPrice: nil, value: nil, data: "0x70a082310000000000000000000000004c44d51cf0d35172fce9d69e2beac728de980e9d", block: BlockTag.latest) { data, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(data)
            print("\nresult: \(data!.respond)\n")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransactionCount() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_getTransactionCount(data: "0x48ff2269e58a373120ffdbbdee3fbcea854ac30a", block: BlockTag.pending) { data, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(data)
            print("\nresult: \(data!.respond)\n")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGasPrice() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_gasPrice { data, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(data)
            print("\nresult: \(data!.respond)\n")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEstimateGas() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_estimateGas(from: nil, to: "0x98C9D14a894d19a38744d41CD016D89Cf9699a51", gas: nil, gasPrice: nil, value: nil, data: "0x095ea7b30000000000000000000000004c44d51cf0d35172fce9d69e2beac728de980e9d0000000000000000000000000000000000000000000000000de0b6b3a7640000") { data, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(data)
            print("\nresult: \(data!.respond)\n")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    // valid data makes test pass, otherwise return nonce too low error
    func testSendRawTransaction() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_sendRawTransaction(data: "0xf8698201798504e3b292008252089444b97fc8befe2ce2f2a776c648e33da4816b01f6018083d8e4e9a0966828a54a0a68aa5dcdd250da3545bd1130511369a3cef86e3a35e4f1fcd752a07acf6701331a8719beafa6484ee35173fd997c9b60e538a638b447cd92c2e06c") { data, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(data)
            print("\nresult: \(data!.respond)\n")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransactionByHash() {
        let expectation = XCTestExpectation()
        eth_JSON_RPC.eth_getTransactionByHash(data: "0xae9d9173248dfae493662fbb200fe79c36c94163c2c25f068d3114024ed216b5") { data, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(data)
            let transaction = data! as Transaction
            print("\ntransaction_hash: \(transaction.hash)\n")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}
