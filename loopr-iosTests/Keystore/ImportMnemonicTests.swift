//
//  ImportMnemonicTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 4/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class ImportMnemonicTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMutipleAddresses() {
        let mnemonic = "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial"
        
        let wallet = Wallet(mnemonic: mnemonic, password: "")
        let publicAddresses = ["0xD964210243c83e4eA59D357824356493c21F8842",
                               "0xf36f8b82A0110a44e888093FC7222208aE867608",
                               "0x825172BfB3cA6b47ac1A912727464a6BDcEd559A",
                               "0x3E16Fe7898d7286893eaf75Abe7697e76546023f",
                               "0x7a0358a5Ccb0c16c8348903519E6042852B4021F"]
        for i in 0..<publicAddresses.count {
            let address = wallet.getKey(at: i).address
            XCTAssertEqual(address.description, publicAddresses[i])
            XCTAssertEqual(address.eip55String, publicAddresses[i])
        }
    }
    
    func testHDDerivationPath() {
        let mnemonic = "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial"
        
        let wallet = Wallet(mnemonic: mnemonic, password: "", path: "m/44'/60'/1'/0/x")
        let publicAddresses = ["0x9aFd24eb14Ec1D7252A6f96BCd313889DBc97559",
                               "0x96514FbEa179fae1883C49faf0aC1150e84687E4",
                               "0x46e99Bf0DB43032eF5e4ae2faC02dD2214d574e3",
                               "0x7BCB81460Da334EFDB02a077269038a2aed9e81f",
                               "0xC88e90A7ed910CEB93E6E9dcD951BC489DF0CF09"]
        for i in 0..<publicAddresses.count {
            let address = wallet.getKey(at: i).address
            XCTAssertEqual(address.description, publicAddresses[i])
            XCTAssertEqual(address.eip55String, publicAddresses[i])
        }
    }

    func testPassword() {
        let mnemonic = "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial"
        
        let wallet = Wallet(mnemonic: mnemonic, password: "123456")
        let publicAddresses = ["0x638DF04C98D44364B2192c27Cc0c7603aAAd8b6D",
                               "0x14CB0Ca4824D844f40Be82469eCBb073e3194279",
                               "0x55527bFC7d4649b5b6619313d9eCE2D1792dfF0a",
                               "0x63b0F57C2A38d70706b0f4d637feCA63DfF6DBbB",
                               "0xCcF1f0C2dDB4196F74c4902aFF199fF19C6a4737"]
        for i in 0..<publicAddresses.count {
            let address = wallet.getKey(at: i).address
            XCTAssertEqual(address.description, publicAddresses[i])
            XCTAssertEqual(address.eip55String, publicAddresses[i])
        }
    }
}
