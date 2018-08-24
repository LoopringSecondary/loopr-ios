//
//  CrypoSwiftTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 8/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import CryptoSwift

class CrypoSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let password: Array<UInt8> = Array("s33krit".utf8)
        let salt: Array<UInt8> = Array("nacllcan".utf8)
        
        let key = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, variant: .sha256).calculate()
        print(key.toHexString())
    }
    
    func test2() {
        let password: Array<UInt8> = Array("cjoUAjJIbs12".utf8)
        let salt: Array<UInt8> = Array("c7c3251fec7c56fb7b1333315edf34f509d58b6c7dcd41fdef292b5b79654c2e".utf8)
        
        let key = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 10240, keyLength: 32, variant: .sha256).calculate()
        print(key.toHexString())
        
        let iv: Array<UInt8> = Array("drowssapdrowssap".utf8)
        let ciphertext: Array<UInt8> = Array("c7c3251fec7c56fb7b1333315edf34f509d58b6c7dcd41fdef292b5b79654c2e".utf8)
        
        let decrypted = try! AES(key: key, blockMode: .CTR(iv: iv), padding: .zeroPadding).decrypt(ciphertext)
        
        print(decrypted.toHexString())
        
    }

}
