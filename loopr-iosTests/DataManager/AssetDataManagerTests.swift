//
//  AssetDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/3/14.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class AssetDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        LoopringSocketIORequest.setup()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        LoopringSocketIORequest.tearDown()
    }
    
    func testLoadTokens() {
        AssetDataManager.shared.loadTokensFromJson()
        XCTAssertFalse(AssetDataManager.shared.getTokens().isEmpty)
    }
    
    func testStartGetBalance() {
        let expectation = XCTestExpectation()
        PriceQuoteDataManager.shared.startGetPriceQuote("USD")
        AssetDataManager.shared.startGetBalance("0x750ad4351bb728cec7d639a9511f9d6488f1e259")
        wait(for: [expectation], timeout: 100.0)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
