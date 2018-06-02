//
//  WalletDataManagerTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class AppWalletDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogout1() {
//        try! ImportWalletUsingPrivateKeyDataManager.shared.unlockWallet(privateKey: "3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe267")
//        ImportWalletUsingPrivateKeyDataManager.shared.complete()
//        let currentWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
//        XCTAssertEqual(currentWallet?.address, "0xE9717c7564d6ED2F764C3c5EB002225ab49e7baB")
//        XCTAssertGreaterThan(AppWalletDataManager.shared.getWallets().count, 0)
//
////        AppWalletDataManager.shared.setConfirmedToLogout()
//        let isLogout = AppWalletDataManager.shared.logout(appWallet: currentWallet!)
//        XCTAssertTrue(isLogout)
//        XCTAssertEqual(AppWalletDataManager.shared.getWallets().count, 0)
//
//        // Setup() will get an empty array of app wallet
//        AppWalletDataManager.shared.setup()
//        XCTAssertEqual(AppWalletDataManager.shared.getWallets().count, 0)
    }

    func testLogout2() {
//        try! ImportWalletUsingPrivateKeyDataManager.shared.unlockWallet(privateKey: "3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe267")
//        ImportWalletUsingPrivateKeyDataManager.shared.complete()
//        let currentWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
//        XCTAssertEqual(currentWallet?.address, "0xE9717c7564d6ED2F764C3c5EB002225ab49e7baB")
//        XCTAssertGreaterThan(AppWalletDataManager.shared.getWallets().count, 0)
//
//        let isLogout = AppWalletDataManager.shared.logout(appWallet: currentWallet!)
//        XCTAssertFalse(isLogout)
//        XCTAssertGreaterThan(AppWalletDataManager.shared.getWallets().count, 0)
    }
    
    func testUnlockWalletUsingPrivateKey() {
        try! ImportWalletUsingPrivateKeyDataManager.shared.unlockWallet(privateKey: "3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe267")
        ImportWalletUsingPrivateKeyDataManager.shared.complete()
        let currentWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
        XCTAssertEqual(currentWallet?.address, "0xE9717c7564d6ED2F764C3c5EB002225ab49e7baB")
    }
    
    func testUnlockWalletUsingMnemonic() {
        /*
        ImportWalletUsingMnemonicDataManager.shared.unlockWallet(mnemonic: "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial")
        let currentWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
        XCTAssertEqual(currentWallet?.address, "0xD964210243c83e4eA59D357824356493c21F8842")
        */
    }

}
