//
//  SignHashTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 5/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios

class SignHashTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSignHashFunction() {
        let address = "0x8cA5fD265499F430a86B34dF241476638C6e08a6"
        let privateKey = "78ba6d34d50fe01acabd5f1480d4c0b5613da044a9f53a027f67f780756c74d5"
        let hashData = "hello world".data(using: .utf8)!
        let mgr = TradeDataManager.shared
        let signatureData = mgr.signHash(privateKey: privateKey, hash: hashData)
        XCTAssertNotNil(signatureData)
        print("signature v: \(signatureData!.v), r: \(signatureData!.r), s: \(signatureData!.s)")
    }

}
