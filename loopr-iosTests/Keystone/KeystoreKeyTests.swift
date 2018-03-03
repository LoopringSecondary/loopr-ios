//
//  KeystoreKeyTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class KeystoreKeyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateKey() {
        let keystoreKey = try! KeystoreKey(password: "password")
        XCTAssertEqual(keystoreKey.address.eip55String, "") 
    }

}
