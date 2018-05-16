//
//  TradeDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/5/15.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class TradeDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    
    func test1() {
        let data = TradeDataManager.shared.encode()
        print(data.hexString)
    }
    
    func test2() {
        let a = "0x87c6117ef0935b1Df3f9D93D9b39516eB8141870"
        let b = "0x77c6117ef0935b1Df3f9D93D9b39516eB8141870"
        
        let text = a.hexBytes
        let cipher = b.hexBytes
        
        var encrypted = [UInt8]()
        
        for t in text.enumerated() {
            encrypted.append(t.element ^ cipher[t.offset])
        }
        
        print(encrypted)
    }
    
}
