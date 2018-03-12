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
            XCTAssert(tokens!.count == 66)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetOrders() {
        let expectation = XCTestExpectation()
        
//        loopring_JSON_RPC.getOrders(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1", orderHash: "0xf0b75ed18109403b88713cd7a1a8423352b9ed9260e39cb1ea0f423e2b6664f0", status: OrderStatus.new.rawValue, market: "lrc-weth") { orders, error in
        
        LoopringAPIRequest.getOrders(owner: nil, orderHash: nil, status: nil, market: "lrc-weth") { orders, error in
            XCTAssert(orders.count == 20)
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
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    
    func testGetTickers() {
        let expectation = XCTestExpectation()
        LoopringAPIRequest.getTickers() { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetFills() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getFills(market: "LRC-WETH", owner: "0xF243c002A1Ec6eA0466ec3C9Dbd745f782B1F058", orderHash: nil, ringHash: nil) { trades, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                XCTFail()
                return
            }
            XCTAssert(trades.count == 10)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTrend() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getTrend(market: "LRC-WETH", interval: "2hr") { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                
                // TODO: Fails to catch the error.
                XCTFail()
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
            
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
            XCTAssertEqual(minedRings!.count, 20)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetCutoff() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getCutoff(address: nil) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                
                // TODO: Fails to catch the error.
                XCTFail()
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
            
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
        
        LoopringAPIRequest.getEstimatedAllocatedAllowance(token: "WETH") { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                
                // TODO: Fails to catch the error.
                XCTFail()
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetSupportedMarket() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getSupportedMarket() { markets, error in
            guard error == nil else {
                print("error=\(String(describing: error))")
                // TODO: Fails to catch the error.
                XCTFail()
                return
            }
            // If the relay support more tokens, we will know.
            XCTAssert(markets.count == 64)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetPortfolio() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getPortfolio(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1") { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                
                // TODO: Fails to catch the error.
                XCTFail()
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetTransactions() {
        let expectation = XCTestExpectation()
        
        LoopringAPIRequest.getTransactions(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1", thxHash: "0xc7756d5d556383b2f965094464bdff3ebe658f263f552858cc4eff4ed0aeafeb", pageIndex: 1, pageSize: 20) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                
                // TODO: Fails to catch the error.
                XCTFail()
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
