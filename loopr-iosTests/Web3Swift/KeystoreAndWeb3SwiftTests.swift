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
        let correctPublicKey: String = "0x638DF04C98D44364B2192c27Cc0c7603aAAd8b6D"
        let correctPrivateKey: String = "9f13480f56489f2601e890f40f357dd42603447192839f8c2288dcb872478967"

        let wallet = Wallet(mnemonic: mnemonic, password: password)
        
        // Public address
        let address = wallet.getKey(at: 0).address
        
        print(address.description)
        XCTAssertEqual(address.description, correctPublicKey)
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
        XCTAssertEqual(privateKey.hexString, correctPrivateKey)
        
        guard let data = Data(hexString: privateKey.hexString) else {
            return // .failure(KeystoreError.failedToImportPrivateKey)
        }
        do {
            let key = try KeystoreKey(password: password, key: data)
            let data = try JSONEncoder().encode(key)
            print(data)
            
            let json = try! JSON(data: data)
            print(json)

            return // .success(dict)
        } catch {
            return // .failure(KeystoreError.failedToImportPrivateKey)
        }
    }

    func testIntegration2() {
        let password: String = "123456"
        
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreTests")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory.absoluteString)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletStoreTests")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory.absoluteString)
        
        let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)

        print(keyStore.accounts.count)
        XCTAssertEqual(keyStore.accounts.count, 0)
        
        /*
        _ = try! keyStore.createAccount(password: password, type: .encryptedKey)
        let account = try! keyStore.createWallet(password: password)
        print(account.address)
        
        XCTAssertEqual(account.address.description, "0x9497633f13568C2C441b3901aC7f240F71692Dd7")
        */

        // _ = try! keyStore.export(account: account, password: password, newPassword: password)
    }
    
    func testIntegration3() {
        let address = "0x638DF04C98D44364B2192c27Cc0c7603aAAd8b6D"
        let privateKey = "9f13480f56489f2601e890f40f357dd42603447192839f8c2288dcb872478967"
        let password: String = "123456"

        guard let data = Data(hexString: privateKey) else {
            return // .failure(KeystoreError.failedToImportPrivateKey)
        }

        do {
            let key = try KeystoreKey(password: password, key: data)
            let data = try JSONEncoder().encode(key)
            print(data)
            
            let json = try! JSON(data: data)
            print(json)
            
            let dict = try JSONSerialization.jsonObject(with: data, options: [])
            print(dict)
            return // .success(dict)
        } catch {
            return // .failure(KeystoreError.failedToImportPrivateKey)
        }
    }
    
    func test11() {
        let a: String! = "0x095ea7b300000000000000000000000017233e07c67d086464fd408148c3abb56245fa640000000000000000000000000000000000000000000000000000000000000000"
        
        let data = Data(hexString: a)!
        
        print(data.hexString)
    }
    
    func test12() {
        var data: JSON = JSON()
        data["hash"] = JSON("hash")
        data["status"] = JSON("status")
        print(data.rawValue)
        print("hello")
    }
}
