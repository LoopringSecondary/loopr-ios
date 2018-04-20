//
//  ImportWalletTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class ImportWalletTests: XCTestCase {

    let keyAddress = Address(eip55: "0x008AeEda4D805471dF9b2A5B0f38A0C3bCBA786b")!
    let walletAddress = Address(eip55: "0x27Ef5cDBe01777D62438AfFeb695e33fC2335979")!
    
    var keyDirectory: URL!
    var walletDirectory: URL!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let fileManager = FileManager.default
        
        keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreTests")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let keyURL = Bundle(for: type(of: self)).url(forResource: "key", withExtension: "json")!
        let keyDestination = keyDirectory.appendingPathComponent("key.json")
        
        try? fileManager.removeItem(at: keyDestination)
        try? fileManager.copyItem(at: keyURL, to: keyDestination)
        
        walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletStoreTests")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let walletURL = Bundle(for: type(of: self)).url(forResource: "wallet", withExtension: "json")!
        let walletDestination = walletDirectory.appendingPathComponent("wallet.json")
        
        try? fileManager.removeItem(at: walletDestination)
        try? fileManager.copyItem(at: walletURL, to: walletDestination)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadKeyStore() {
        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        
        let keyAccount = keyStore.account(for: keyAddress)
        XCTAssertNotNil(keyAccount)
        
        let walletAccount = keyStore.wallet(for: walletAddress)
        XCTAssertNotNil(walletAccount)
    }
    
    func testCreateKey() {
        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)

        let newAccount1 = try! keyStore.createAccount(password: "password", type: .encryptedKey)
        
        XCTAssertNotNil(keyStore.account(for: newAccount1.address))
        XCTAssertEqual(keyStore.accounts.count, 3)
        
        let newAccount2 = try! keyStore.createAccount(password: "password", type: .encryptedKey)
        
        XCTAssertNotNil(keyStore.account(for: newAccount2.address))
        XCTAssertEqual(keyStore.accounts.count, 4)
        
        let privateKeyData = try! keyStore.exportPrivateKey(account: newAccount2, password: "password")
        let key = try! KeystoreKey(password: "password", key: privateKeyData)
        print(key.address.eip55String)
        
        XCTAssertEqual(newAccount2.address, key.address)
    }

    func testMnemonicToKeystore() {
        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        let account = try! keyStore.import(mnemonic: "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial", password: "")
        print(account.url.absoluteString)
        XCTAssertEqual(account.address.eip55String, "0xD964210243c83e4eA59D357824356493c21F8842")
    }
}
