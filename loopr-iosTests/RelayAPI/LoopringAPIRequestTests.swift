//
//  loopr_iosTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 1/31/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class LoopringAPIRequestTests: XCTestCase {
    
    let testAddress = "0x87c6117ef0935b1Df3f9D93D9b39516eB8141870"
    
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
        LoopringAPIRequest.getBalance(owner: testAddress) { assets, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotNil(assets)
            XCTAssertNotEqual(assets.count, 0)
            
            for asset in assets {
                print("\(asset.symbol): \(asset.balance)")
            }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetOrders() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getOrders(owner: testAddress, orderHash: nil, status: nil, market: "lrc-weth") { orders, error in
            XCTAssertNotNil(orders)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetOrderBook() {
        let expectation = XCTestExpectation()
        OrderBookDataManager.shared.getOrderBookFromServer(market: "lrc-weth", completionHandler: { orders, error in
            XCTAssertNotNil(orders)
            XCTAssertNotEqual(orders!.count, 0)
            expectation.fulfill()
        })
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
    
    func testGetMarkets() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getMarkets() { markets, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            XCTAssertNotEqual(markets.count, 0)
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
        LoopringAPIRequest.getCutoff(address: testAddress) { date, error in
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
        LoopringAPIRequest.getEstimatedAllocatedAllowance(owner: testAddress, token: "WETH") { amount, error in
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
        
        LoopringAPIRequest.getSupportedMarket() { pairs, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            // If the relay support more tokens, we will know.
            XCTAssertNotNil(pairs)
            XCTAssertNotEqual(pairs!.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetSupportedTokens() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getSupportedTokens(completionHandler: { (tokens, error) in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            // If the relay support more tokens, we will know.
            XCTAssertNotNil(tokens)
            XCTAssertNotEqual(tokens!.count, 0)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransactions() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getTransactions(owner: testAddress, symbol: "LRC", thxHash: nil, pageIndex: 1, pageSize: 20) { transactions, error in
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
        LoopringAPIRequest.unlockWallet(owner: testAddress) { result, error in
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
    
    func testGetPortfolio() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getPortfolio(owner: "0x329B97A3E8eC8a8c23D4bD54803e74A9eE66CbcB") { result, error in
            guard error == nil && result != nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            print(result!)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetFrozenLRCFee() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getFrozenLRCFee(owner: "0x329B97A3E8eC8a8c23D4bD54803e74A9eE66CbcB") { (frozenLRCFee, error) in
            guard error == nil && frozenLRCFee != nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(frozenLRCFee)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetEstimateGasPrice() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getEstimateGasPrice { (gasPrice, error) in
            guard error == nil && gasPrice != nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssertNotNil(gasPrice)
            print(gasPrice!)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testNotifyTransactionSubmitted() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.notifyTransactionSubmitted(txHash: "0x890db35af7d66d117e4feba62a041fb5ec7d5e432b19c96a090e1ff482d1c5ef") { (result, error) in
            guard error == nil && result != nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            print(result!)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}
