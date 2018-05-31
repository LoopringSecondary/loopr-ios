//
//  CreateMnemonicTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

struct TestDataset {
    let mnemonic: [String]
    let publicAddress: String
    let privateKey: String
}

class CreateMnemonicTests: XCTestCase {
    
    let password: String = ""
    
    var testDatasets: [TestDataset] = []
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let mnemonicString1 = "soda code cannon sketch boss fancy tail lesson forum figure gloom history dismiss sketch lady control wolf hello away pave priority story design trial"
        let mnemonic1 = mnemonicString1.components(separatedBy: " ")
        XCTAssertEqual(mnemonic1.count, 24)
        let testDataset1 = TestDataset(mnemonic: mnemonic1, publicAddress: "0xD964210243c83e4eA59D357824356493c21F8842", privateKey: "63946b4f415ee0fb2430890e5bec7ecd7bf27f34f4c0bd11d42273e595965fbd")
        testDatasets.append(testDataset1)
        
        let mnemonicString2 = "stuff barely donate club pipe gesture liberty tumble never recall kite fun reject fatigue decorate tennis hawk cause outer drink slow liar truly plate"
        let mnemonic2 = mnemonicString2.components(separatedBy: " ")
        XCTAssertEqual(mnemonic2.count, 24)
        let testDataset2 = TestDataset(mnemonic: mnemonic2, publicAddress: "0xDb521561711e96895C0100c552403F4d32018678", privateKey: "65cb99613ac0ecf9fdf64046065dd0ff18ec86ac922ddc885c0d3efa7f97c17a")
        testDatasets.append(testDataset2)
        
        let mnemonicString3 = "early this cart keen grape inspire oppose select giraffe urge used crowd review royal fix deer property chimney cage abstract whip same defense absorb"
        let mnemonic3 = mnemonicString3.components(separatedBy: " ")
        XCTAssertEqual(mnemonic3.count, 24)
        let testDataset3 = TestDataset(mnemonic: mnemonic3, publicAddress: "0x5E505f4A874E36DCe7bdD53719a3372A9BD26715", privateKey: "c9e857e62aac9c85d2206580be3d915e0201d24e6a26f2dcc081ea3e2e43c35d")
        testDatasets.append(testDataset3)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMnemonic12() {
        let mnemonic = Mnemonic.generate(strength: 128)
        
        print(mnemonic)
        XCTAssertEqual(mnemonic.split(separator: " ").count, 12)
        
        let wallet = Wallet(mnemonic: mnemonic, password: password)

        // Public address
        let address = wallet.getKey(at: 0).address
        
        print(address.description)
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
    }
    
    func testMnemonic24() {
        let mnemonic = Mnemonic.generate(strength: 256)
        
        print(mnemonic)
        XCTAssertEqual(mnemonic.split(separator: " ").count, 24)
        
        let wallet = Wallet(mnemonic: mnemonic, password: password)
        
        // Public address
        let address = wallet.getKey(at: 0).address
        
        print(address.description)
        
        // Private key
        let privateKey = wallet.getKey(at: 0).privateKey
        print(privateKey.hexString)
    }

}
