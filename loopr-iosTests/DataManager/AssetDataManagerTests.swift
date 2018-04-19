//
//  CurrentAppWalletDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/3/14.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
@testable import BigInt

class CurrentAppWalletDataManagerTests: XCTestCase {
    
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
        TokenDataManager.shared.loadTokensFromJson()
        XCTAssertFalse(TokenDataManager.shared.getTokens().isEmpty)
    }
    
    func testStartGetBalance() {
        let expectation = XCTestExpectation()
        PriceQuoteDataManager.shared.startGetPriceQuote("USD")
        CurrentAppWalletDataManager.shared.startGetBalance()
        wait(for: [expectation], timeout: 100.0)
    }
    
    func testGetAmount() {
        let amount = "0x56bc75e2d63100000"
        let num = Asset.getAmount(of: "LRC", from: amount)
        XCTAssertNotNil(num)
        XCTAssertEqual(num, 100)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
