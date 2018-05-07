//
//  PlaceOrderDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/5/6.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios

class PlaceOrderDataManagerTests: XCTestCase {
    
    func _keystore() {
        let start = Date()
        let wallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
        var gethAccount: GethAccount?
        
        // Get Keystore string value
        let keystoreStringValue: String = wallet!.getKeystore()
        print(keystoreStringValue)
        
        // Create key directory
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreSendAssetViewController")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletSendAssetViewController")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory)
        
        // Save the keystore string value to keyDirectory
        let fileURL = keyDirectory.appendingPathComponent("key.json")
        try! keystoreStringValue.write(to: fileURL, atomically: false, encoding: .utf8)
        
        print(keyDirectory.absoluteString)
        let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
        
        let gethKeystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
        
        gethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: wallet!.getPassword())
        
        print("current address: \(gethAccount!.getAddress().getHex())")
        let end = Date()
        let timeInterval: Double = end.timeIntervalSince(start)
        print("Time to _keystore: \(timeInterval) seconds")
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        _keystore()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testHashData() {
        var datass: Data = Data()
        // "0x17233e07c67d086464fD408148c3ABB56245FA64" delegate address
        datass.append(contentsOf: [23, 35, 62, 7, 198, 125, 8, 100, 100, 253, 64, 129, 72, 195, 171, 181, 98, 69, 250, 100])
        // "0x8311804426a24495bd4306daf5f595a443a52e32" owner
        datass.append(contentsOf: [131, 17, 128, 68, 38, 162, 68, 149, 189, 67, 6, 218, 245, 245, 149, 164, 67, 165, 46, 50])
        // "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" tokens addr
        datass.append(contentsOf: [192, 42, 170, 57, 178, 35, 254, 141, 10, 14, 92, 79, 39, 234, 217, 8, 60, 117, 108, 194])
        // "0xEF68e7C694F40c8202821eDF525dE3782458639f" toknb addr
        datass.append(contentsOf: [239, 104, 231, 198, 148, 244, 12, 130, 2, 130, 30, 223, 82, 93, 227, 120, 36, 88, 99, 159])
        // "0xb94065482ad64d4c2b9252358d746b39e820a582" exchanger wallet addr
        datass.append(contentsOf: [185, 64, 101, 72, 42, 214, 77, 76, 43, 146, 82, 53, 141, 116, 107, 57, 232, 32, 165, 130])
        // "0x38c2657f780e4b286dbb8275e00b508c7afa3900" auth wallet addr
        datass.append(contentsOf: [56, 194, 101, 127, 120, 14, 75, 40, 109, 187, 130, 117, 224, 11, 80, 140, 122, 250, 57, 0])
        // "0x12cde439d834e000" 1354990000000000000 amounts
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 205, 228, 57, 216, 52, 224, 0])
        // "0x3635c9adc5dea00000" 1000000000000000000000 amountb
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 53, 201, 173, 197, 222, 160, 0, 0])
        // "0x5ae96f2e" 1525247790 validSince
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 233, 111, 46])
        // "0x5aeac0ae" 1525334190 validUntil
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 234, 192, 174])
        // 0x1B7A5F826F460000 1980000000000000000 LRC FEE
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 122, 95, 130, 111, 70, 0, 0])
        // buyNoMoreThan true
        datass.append(contentsOf: [1])
        // marginSplit 50%
        datass.append(contentsOf: [50])
        
        let SignatureData = web3swift.sign(message: datass)!
        print(SignatureData.r)
        print(SignatureData.s)
        print(SignatureData.v)
    }
    
    func testBigValue() {
        var a = PlaceOrderDataManager.shared._encode(1, "LRC")
        print(a)
        a = RelayAPIConfiguration.delegateAddress.hexBytes
        print(a)
        let now = Int64(Date().timeIntervalSince1970)
        a = PlaceOrderDataManager.shared._encode(now)
        print(a)
    }
    
    func testCancelOrder() {
        let order = OriginalOrder(delegate: "0x17233e07c67d086464fD408148c3ABB56245FA64", address: "0xb94065482Ad64d4c2b9252358D746B39e820A582", side: "sell", tokenS: "LRC", tokenB: "WETH", validSince: Int64("0x5aeff2b5".dropFirst(2), radix: 16)!, validUntil: Int64("0x5af14435".dropFirst(2), radix: 16)!, amountBuy: 3, amountSell: 2000, lrcFee: 5.53, buyNoMoreThanAmountB: false, market: "LRC-WETH", hash: "0xefe541de23ef69eac1e2db0800eaf3c5f4180183fe0ebcf82ef2b2594a2cb054", v: 27, r: "0xb994a2816b643fa2b4e97add1d3c9651fd2a1e29ea6ad8d92b89eadabf411e32", s: "0x19342c8b83f314812af9ff18c196368b34549151d3e30026223f91ca01bc0894")
        let data = SendCurrentAppWalletDataManager.shared._encodeOrder(order: order)
        print(data.hexString)
    }
}
