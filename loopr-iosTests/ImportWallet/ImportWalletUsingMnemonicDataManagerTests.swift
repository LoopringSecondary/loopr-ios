//
//  ImportWalletUsingMnemonicDataManagerTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 6/16/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class ImportWalletUsingMnemonicDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test1() {
        ImportWalletUsingMnemonicDataManager.shared.mnemonic = "rebuild night flat practice twist snake during venture own beef useful jacket fly category unable crumble wreck salt enable spot alert good bottom harsh"
        ImportWalletUsingMnemonicDataManager.shared.walletName = "hello"
        ImportWalletUsingMnemonicDataManager.shared.password = "1234567890"
        ImportWalletUsingMnemonicDataManager.shared.generateAddresses()
        ImportWalletUsingMnemonicDataManager.shared.complete { appWallet, error in
            XCTAssertNotNil(appWallet)
            XCTAssertEqual(appWallet!.address.lowercased(), "0x3572d61b6942f410f3ea43b5c4c2ed5c2c79276e".lowercased())
            SendCurrentAppWalletDataManager.shared._keystore()
        }
    }

}
