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
        JSON_RPC.getBalance() { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            // print("response = \(json)")
            
            // TODO: verify the response
        }
    }
    
    func testGetOrder() {
        JSON_RPC.getOrders() { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            let json = JSON(data)
            // print("response = \(json)")
            
            // TODO: verify the response
        }
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

}
