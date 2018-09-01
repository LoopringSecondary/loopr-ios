//
//  PriceQuoteDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/3/14.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class PriceQuoteDataManagerTests: XCTestCase {
    
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
    
    func testStartGetPriceQuote() {
        let expectation = XCTestExpectation()
        PriceDataManager.shared.startGetPriceQuote()
        wait(for: [expectation], timeout: 100.0)
    }

}
