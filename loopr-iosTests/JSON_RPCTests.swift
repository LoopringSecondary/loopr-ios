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

class JSON_RPCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetBalance() {
        let expectation = XCTestExpectation()

        JSON_RPC.getBalance(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1") { data, response, error in
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
    
    func testGetOrder() {
        let expectation = XCTestExpectation()

        JSON_RPC.getOrders(pageSize: 10) { orders, error in
            XCTAssert(orders.count == 10)
            
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetDepth() {
        JSON_RPC.getDepth() { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            // print("response = \(json)")
            
            // TODO: verify the response
        }
    }
    
    func testGetTickers() {
        JSON_RPC.getTickers() { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            print("response = \(json)")
            
            // TODO: verify the response
        }
    }
    
    func testGetFills() {
        let expectation = XCTestExpectation()

        JSON_RPC.getFills(market: "LRC-WETH", owner: "0x8888f1f195afa192cfee860698584c030f4c9db1", orderHash: "0xee0b482d9b704070c970df1e69297392a8bb73f4ed91213ae5c1725d4d1923fd", ringHash: "0x2794f8e4d2940a2695c7ecc68e10e4f479b809601fa1d07f5b4ce03feec289d5", pageIndex: 1, pageSize: 20) { data, response, error in
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
    
    func testGetTrend() {
        let expectation = XCTestExpectation()
        
        JSON_RPC.getTrend(market: "LRC-WETH", interval: "2hr") { data, response, error in
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
        
        JSON_RPC.getRingMined(ringHash: "0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238", pageIndex: 1, pageSize: 20) { data, response, error in
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
    
    func testGetCutoff() {
        let expectation = XCTestExpectation()
        
        JSON_RPC.getCutoff(address: nil) { data, response, error in
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
        
        JSON_RPC.getPriceQuote(currency: "USD") { data, response, error in
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
    
    func testGetEstimatedAllocatedAllowance() {
        let expectation = XCTestExpectation()
        
        JSON_RPC.getEstimatedAllocatedAllowance(token: "WETH") { data, response, error in
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
        
        JSON_RPC.getSupportedMarket() { markets, error in
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
        
        JSON_RPC.getPortfolio(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1") { data, response, error in
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
        
        JSON_RPC.getTransactions(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1", thxHash: "0xc7756d5d556383b2f965094464bdff3ebe658f263f552858cc4eff4ed0aeafeb", pageIndex: 1, pageSize: 20) { data, response, error in
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
