//
//  SendCurrentAppWalletDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/3/20.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class SendCurrentAppWalletDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadGasLimits() {
        let mgr = GasDataManager.shared
        mgr.loadGasLimitsFromJson()
        XCTAssertEqual(mgr.getGasLimits().count, 8)
    }
    
    func testGetNonceFromServerSynchronous() {
        let mgr = SendCurrentAppWalletDataManager.shared
        mgr.getNonceFromServerSynchronous()
    }
    
    func test() {
        
    }
    
}
