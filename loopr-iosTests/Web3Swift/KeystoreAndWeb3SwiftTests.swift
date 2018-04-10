//
//  KeystoreAndWeb3SwiftTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 4/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios

class KeystoreAndWeb3SwiftTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIntegration() {
        let mnemonic: String = "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial"
        let password: String = "123456"
        
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreTests")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletStoreTests")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        
        let account = try! keyStore.import(mnemonic: mnemonic, password: password)
        print(account.url.absoluteString)
        do {
            let keystoreFileValue = try String(contentsOf: account.url, encoding: .utf8)
            print(keystoreFileValue)
        } catch {
            
        }
        
        let data = try! keyStore.export(account: account, password: password, newPassword: password)
        let json = try? JSONSerialization.jsonObject(with: data)
        if let json = json {
            print("Person JSON:\n" + String(describing: json) + "\n")
            //Prints: Person JSON: { age = 20; name = Yuri; }
        }

        let wallet = Wallet(mnemonic: mnemonic, password: password)
        
        // Public address
        let address = wallet.getKey(at: 0).address
        
        print(address.description)
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
    }

    func testIntegration2() {
        let password: String = "123456"
        
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreTests")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletStoreTests")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        
        try! keyStore.createAccount(password: password, type: .encryptedKey)
        let account = try! keyStore.createWallet(password: password)

        let data = try! keyStore.export(account: account, password: password, newPassword: password)
    }
    
    func testIntegration3() {
        let password: String = "123456"
        try! KeystoreKey.init(password: password)
    }
}
