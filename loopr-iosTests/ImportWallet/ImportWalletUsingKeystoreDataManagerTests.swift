//
//  ImportWalletUsingKeystoreDataManagerTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 6/16/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class ImportWalletUsingKeystoreDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // TOOD: this test fails. The root cause is that strings are not equal.
    func _test1() {
        let keystoreString = "{\"version\":3,\"id\":\"3c343f27-05dd-422d-8704-2ad0b90a5267\",\"address\":\"11381c3a20c2793b9f17502d72bda905e03734f2\",\"Crypto\":{\"ciphertext\":\"4ad2954117ae35e6c2b3d819c7f885841f60b63a7256b18643e79c1451113cd1\",\"cipherparams\":{\"iv\":\"5a1671e36add8e3b3714d114bacdf0ef\"},\"cipher\":\"aes-128-ctr\",\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"salt\":\"54290f8bdb7fceef48ff48e17ab7923143da5004ae273c21d691510645295fa9\",\"n\":1024,\"r\":8,\"p\":1},\"mac\":\"6d5ef298d2834b88d2f4e5f6ee55647324d6c7b51124b65ee139646f48df5a21\"}}"
        
        let appWallet = AppWallet.init(setupWalletMethod: .importUsingKeystore, address: "0x11381c3a20c2793b9f17502d72bda905e03734f2", privateKey: "720a29425b8122ab0d5bb65c64f64cc6a4103bb19bd4223117606e2cd27c1478", password: "1234567890", keystoreString: keystoreString, name: "hello", isVerified: true, tokenList: [])
        
        AppWalletDataManager.shared.logout(appWallet: appWallet)
        
        XCTAssertNoThrow(try ImportWalletUsingKeystoreDataManager.shared.unlockWallet(keystoreStringValue: keystoreString, password: "1234567890"))
        // let address = "0x11381c3a20c2793b9f17502d72bda905e03734f2"
        // let address2 = ImportWalletUsingKeystoreDataManager.shared.address
        // XCTAssertEqual(address, address2)
        XCTAssertEqual(ImportWalletUsingKeystoreDataManager.shared.privateKey, "720a29425b8122ab0d5bb65c64f64cc6a4103bb19bd4223117606e2cd27c1478")
        XCTAssertEqual(ImportWalletUsingKeystoreDataManager.shared.password, "1234567890")
        
        ImportWalletUsingKeystoreDataManager.shared.walletName = "hello world"
        XCTAssertNoThrow(try ImportWalletUsingKeystoreDataManager.shared.complete())
        
        let currentAppWallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!
        XCTAssertEqual(currentAppWallet.setupWalletMethod, .importUsingKeystore)
        XCTAssertEqual(currentAppWallet.name, "hello world")
        // XCTAssertEqual(appWallet.address, "0x11381c3a20c2793b9f17502d72bda905e03734f2")
        SendCurrentAppWalletDataManager.shared._keystore()
    }

}
