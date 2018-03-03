//
//  KeystoneTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 3/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
@testable import loopr_ios

class WalletTests: XCTestCase {
    let words = "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal"
    let password = "TREZOR"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSeed() {
        let wallet = Wallet(mnemonic: words, password: password)
        XCTAssertEqual(wallet.seed.hexString, "7ae6f661157bda6492f6162701e570097fc726b6235011ea5ad09bf04986731ed4d92bc43cbdee047b60ea0dd1b1fa4274377c9bf5bd14ab1982c272d8076f29")
    }
    
    func testSeedNoPassword() {
        let wallet = Wallet(mnemonic: words, password: "")
        XCTAssertEqual(wallet.seed.hexString, "354c22aedb9a37407adc61f657a6f00d10ed125efa360215f36c6919abd94d6dbc193a5f9c495e21ee74118661e327e84a5f5f11fa373ec33b80897d4697557d")
    }
    
}
