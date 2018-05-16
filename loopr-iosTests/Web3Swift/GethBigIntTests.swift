//
//  GethBigIntTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 5/5/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios

class GethBigIntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test1() {
        let value: Double = 1.0
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        XCTAssertEqual(amount!.getString(10), "1000000000000000000")
    }

    func test2() {
        let value: Double = 2.1
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        XCTAssertEqual(amount!.getString(10), "2100000000000000000")
    }

    func test3() {
        // This is valid value in ether.
        let value: Double = 1.123456789123456789
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        print(amount!.getString(10))
        XCTAssertEqual(amount!.getString(10), "1123456789123456789")
    }
    
    func test4() {
        let value: String = "1.123456789123456789"
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        XCTAssertEqual(amount!.getString(10), "1123456789123456789")
    }
    
    func test5() {
        let value: String = "1.1234567891234567891234567"
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNil(amount)
    }
    
    func test6() {
        let value: String = "1."
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        XCTAssertEqual(amount!.getString(10), "1000000000000000000")
    }

    func test7() {
        let value: String = "1..."
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNil(amount)
    }
    
    func test8() {
        let value: String = "1234567891234567890.123456789123456789"
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        print(amount!.getString(10))
        XCTAssertEqual(amount!.getString(10), "1234567891234567890123456789123456789")
    }

    func test9() {
        let value: String = "00000.123456789123456789"
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        print(amount!.getString(10))
        XCTAssertEqual(amount!.getString(10), "123456789123456789")
    }
    
    func test10() {
        let value: String = "00000.000123456789"
        let amount = GethBigInt.generate(valueInEther: value, symbol: "ETH")
        XCTAssertNotNil(amount)
        print(amount!.getString(10))
        XCTAssertEqual(amount!.getString(10), "123456789000000")
    }

    func test11() {
        let value: String = "00000.000123456789"
        let amount = GethBigInt.generate(valueInEther: value, symbol: "LRC")
        XCTAssertNotNil(amount)
        print(amount!.getString(10))
        XCTAssertEqual(amount!.getString(10), "123456789000000")
    }
    
    func test12() {
        let value: String = "00000.0001234567"
        let amount = GethBigInt.generate(value, 10)
        XCTAssertNotNil(amount)
        print(amount!.getString(10))
        XCTAssertEqual(amount!.getString(10), "1234567")
    }

    func test13() {
        print(GethBigInt.init(288).hexString)
    }
}
