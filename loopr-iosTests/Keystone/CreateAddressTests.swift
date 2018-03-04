//
//  CreateAddressTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios
import CryptoSwift

class CreateAddressTests: XCTestCase {
    
    let password: String = "password"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateKey_1() {
        // Generate a key
        let keystoreKey1 = try! KeystoreKey(password: password)

        // Get Private key
        let decrypted1 = try! keystoreKey1.decrypt(password: password)
        // XCTAssertEqual(decrypted1, keystoreKey1.crypto.cipherText)
        
        // Public key
        print(keystoreKey1.address.eip55String)
        
        // Private key
        print(decrypted1.hexString)
        
        let keystoneKey2 = try! KeystoreKey(password: password, key: decrypted1)
        
        XCTAssertEqual(keystoreKey1.address, keystoneKey2.address)
    }

    func testCreateKey_2() {
        // Generate a key
        let keystoreKey1 = try! KeystoreKey(password: password)
        
        // Get Private key
        let decrypted1 = try! keystoreKey1.decrypt(password: password)
        // XCTAssertEqual(decrypted1, keystoreKey1.crypto.cipherText)
        
        // Public key
        print(keystoreKey1.address.eip55String)
        
        // Private key
        print(decrypted1.hexString)

        // If an invalid password is used, then it should return an invalid input error.
        XCTAssertThrowsError(try KeystoreKey(password: "", key: decrypted1)) { error in
            guard case CryptoSwift.PKCS5.PBKDF2.Error.invalidInput = error else {
                XCTFail("Expected invalid input error")
                return
            }
        }
    }
    
    func testMeasure() {
        self.measure {
           _ = try! KeystoreKey(password: password)
        }
    }

}
