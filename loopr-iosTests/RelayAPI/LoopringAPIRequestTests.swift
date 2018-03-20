//
//  loopr_iosTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
import SwiftyJSON

class LoopringAPIRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // its ok to pass nil or real value to method, e.g. owner, same as below
    func testGetBalance() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getBalance(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1") { tokens, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            // 66 is the num of our current supported token list
            XCTAssertNotNil(tokens)
            XCTAssertNotEqual(tokens!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetOrders() {
        let expectation = XCTestExpectation()
//        loopring_JSON_RPC.getOrders(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1", orderHash: "0xf0b75ed18109403b88713cd7a1a8423352b9ed9260e39cb1ea0f423e2b6664f0", status: OrderStatus.new.rawValue, market: "lrc-weth") { orders, error in
        
        LoopringAPIRequest.getOrders(owner: nil, orderHash: nil, status: nil, market: "lrc-weth") { orders, error in
            XCTAssertNotNil(orders)
            XCTAssertNotEqual(orders!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetDepth() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getDepth(market: "LRC-WETH", length: 10) { depth, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(depth)
            XCTAssertNotEqual(depth!.sell.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTicker() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getTicker() { tickers, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(tickers)
            XCTAssertNotEqual(tickers!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetFills() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getFills(market: "LRC-WETH", owner: nil, orderHash: nil, ringHash: nil) { trades, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(trades)
            XCTAssertNotEqual(trades!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTrend() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getTrend(market: "LRC-WETH", interval: "2Hr") { trends, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(trends)
            XCTAssertNotEqual(trends!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetRingMined() {
        
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getRingMined(ringHash: nil, pageIndex: 1, pageSize: 20) { minedRings, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(minedRings)
            XCTAssertEqual(minedRings!.count, 2)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetCutoff() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getCutoff(address: "0x750ad4351bb728cec7d639a9511f9d6488f1e259") { date, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(date)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetPriceQuote() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getPriceQuote(currency: "USD") { price, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(price)
            print("\nprice.currency:\(price!.currency)\n")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetEstimatedAllocatedAllowance() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getEstimatedAllocatedAllowance(owner: "0x750ad4351bb728cec7d639a9511f9d6488f1e259", token: "WETH") { amount, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(amount)
            print(amount!)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetSupportedMarket() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getSupportedMarket() { markets, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            // If the relay support more tokens, we will know.
            XCTAssertNotNil(markets)
            XCTAssertNotEqual(markets!.count, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransactions() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getTransactions(owner: "0x48ff2269e58a373120FFdBBdEE3FBceA854AC30A", symbol: "LRC", thxHash: nil, pageIndex: 1, pageSize: 20) { transactions, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(transactions)
            XCTAssertNotEqual(transactions!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testUnlockWallet() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.unlockWallet(owner: "0x48ff2269e58a373120FFdBBdEE3FBceA854AC30A") { result, error in
            guard error == nil && result != nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertEqual(result!, "unlock_notice_success")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}
