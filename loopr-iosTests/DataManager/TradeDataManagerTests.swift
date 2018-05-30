//
//  TradeDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/5/15.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
import CryptoSwift
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
        let a = "0x03a1295401d7588e4f81609c10865217ec7ac88e210f78de29bbd0eea9d6b8a6"
        let b = "0xdf1beb271ae416a489a5df9e909e9a5eab385637e277d781947965d38d437d96"
        
        let text = a.hexBytes
        let cipher = b.hexBytes
        
        var encrypted = [UInt8]()
        
        for t in text.enumerated() {
            encrypted.append(t.element ^ cipher[t.offset])
        }
        
        print(encrypted)
    }
    
    func test3() {
        let data = "dcbac2731b334e2ac624bf028018c84947429eb9c378af5fbdc2b53d2495c530b94065482ad64d4c2b9252358d746b39e820a5820000"
        let data1 = Data(bytes: data.hexBytes)
        let hash = data1.sha3(SHA3.Variant.keccak256)
        print(hash.hexString)
    }
    
    func test4() {
        let result = GasDataManager.shared.getGasAmount(by: "lrcFee", in: "LRC")
        print(result)
    }
}
