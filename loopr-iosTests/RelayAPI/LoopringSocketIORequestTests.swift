//
//  LoopringSocketIORequestTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/3/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
@testable import SocketIO
import SwiftyJSON

class LoopringSocketIORequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        LoopringSocketIORequest.shared.setup()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetBalance() {
        let expectation = XCTestExpectation()
        LoopringSocketIORequest.shared.getBalance(owner: "0x847983c3a34afa192cfee860698584c030f4c9db1")
        
//        expectation.fulfill()
        
        wait(for: [expectation], timeout: 100.0)
    }
    
}
