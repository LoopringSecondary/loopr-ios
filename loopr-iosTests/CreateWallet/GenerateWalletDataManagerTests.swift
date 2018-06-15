//
//  GenerateWalletDataManagerTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 6/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class GenerateWalletDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test1() {
        GenerateWalletDataManager.shared.new()
        XCTAssertEqual(GenerateWalletDataManager.shared.getMnemonics().count, 12)
        
        XCTAssertFalse(GenerateWalletDataManager.shared.verify())
        
        GenerateWalletDataManager.shared.setWalletName("hello world")
        GenerateWalletDataManager.shared.setPassword("123456")
        
        let expectation = XCTestExpectation()
        GenerateWalletDataManager.shared.complete { (appWallet, error) in
            XCTAssertNil(error)
            XCTAssertEqual(appWallet!.name, "hello world")
            XCTAssertEqual(appWallet!.getPassword(), "123456")
            XCTAssertEqual(appWallet!.getKeystorePassword(), "123456")
            XCTAssertEqual(appWallet!.setupWalletMethod, QRCodeMethod.create)
            XCTAssertEqual(CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address, appWallet!.address)
            SendCurrentAppWalletDataManager.shared._keystore()
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 100.0)
    }

}
