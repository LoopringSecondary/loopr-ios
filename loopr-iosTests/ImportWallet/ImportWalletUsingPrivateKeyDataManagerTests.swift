//
//  ImportWalletUsingPrivateKeyDataManagerTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 6/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class ImportWalletUsingPrivateKeyDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test1() {
        let privateKey = "f81747000219e1ea0e5e75474782a2f06d1dafa23222bf72fd5f3ed6a89e3d6b"
        XCTAssertNoThrow(try ImportWalletUsingPrivateKeyDataManager.shared.importWallet(privateKey: privateKey))
        // XCTAssertNoThrow(try ImportWalletUsingPrivateKeyDataManager.shared.complete())
    }

}
