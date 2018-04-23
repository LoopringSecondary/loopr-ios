//
//  ImportPrivateKeyTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 4/20/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class ImportPrivateKeyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test1() {
        let address = "0x638DF04C98D44364B2192c27Cc0c7603aAAd8b6D"
        let privateKey = "9f13480f56489f2601e890f40f357dd42603447192839f8c2288dcb872478967"
        try! ImportWalletUsingPrivateKeyDataManager.shared.unlockWallet(privateKey: privateKey)
        ImportWalletUsingPrivateKeyDataManager.shared.complete()
        
        if let currentAppWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet() {
            XCTAssertEqual(currentAppWallet.address.description, address)
        }
    }

}
