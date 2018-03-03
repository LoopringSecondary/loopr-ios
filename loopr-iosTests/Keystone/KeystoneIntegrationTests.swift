//
//  KeystoneIntegrationTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class KeystoneIntegrationTests: XCTestCase {
    
    // Test dataset:
    // private key : public key
    let keyPair = [
        "3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe267": "0xE9717c7564d6ED2F764C3c5EB002225ab49e7baB",
        "3a1076bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe269": "0x1f053ae5Ca41d8B3Bc20d1E42E5F9C6b7612ACC1",
        "3a1176bf45ab87712ad64ccb3b10217737f7faacbf2872e88fdd9a537d8fe269": "0x97a01b6807E23718eC4ecAae1DA04863f2866a43",
    ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test1() {
        for (privateKey, publicKey) in keyPair {
            let privateKeyData = Data(hexString: privateKey)!
            let keystoneKey = try! KeystoreKey(password: "password", key: privateKeyData)
            XCTAssertEqual(publicKey, keystoneKey.address.eip55String)
        }
    }

}
