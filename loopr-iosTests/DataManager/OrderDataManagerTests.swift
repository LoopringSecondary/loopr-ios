//
//  OrderDataManagerTests.swift
//  loopr-iosTests
//
//  Created by kenshin on 2018/5/2.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios


class OrderDataManagerTests: XCTestCase {
    
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
    
    func testHashData() {
        var parameters: Array<[UInt8]> = Array()
//        parameters.append("0x17233e07c67d086464fD408148c3ABB56245FA64") // delegate
//        parameters.append("0x8311804426a24495bd4306daf5f595a443a52e32") // owner
//        parameters.append("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2") // tokens
//        parameters.append("0xEF68e7C694F40c8202821eDF525dE3782458639f") // tokenb
//        parameters.append("0xb94065482ad64d4c2b9252358d746b39e820a582") // walletaddress
//        parameters.append("0x38c2657f780e4b286dbb8275e00b508c7afa3900") // authaddr
//
//
//        parameters.append("0x12cde439d834e000") // amounts  1354990000000000000
//        parameters.append("0x3635c9adc5dea00000") // amount b 1000000000000000000000
//        parameters.append("0x5ae96f2e") // validsince  1525247790
//        parameters.append("0x5aeac0ae") // validuntil  1525334190
//        parameters.append("0x1b7a5f826f460000") // lrc fee  1980000000000000000
//        parameters.append(UInt8(1)) // buy no more than
//        parameters.append(50) // magin sp
        var value = "0x17233e07c67d086464fD408148c3ABB56245FA64".hexBytes //dele
        parameters.append(value)
        value = "0x8311804426a24495bd4306daf5f595a443a52e32".hexBytes // ownre
        parameters.append(value)
        value = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2".hexBytes // tokens
        parameters.append(value)
        value = "0xEF68e7C694F40c8202821eDF525dE3782458639f".hexBytes //toknb
        parameters.append(value)
        value = "0xb94065482ad64d4c2b9252358d746b39e820a582".hexBytes //walletaddr
        parameters.append(value)
        value = "0x38c2657f780e4b286dbb8275e00b508c7afa3900".hexBytes // authaddr
        parameters.append(value)

        
        var parameter2: Array<Any> = Array()
        var value2 = GethBigInt(1354990000000000000)!  // amounts
        parameter2.append(value2)
        
        value2 = GethBigInt.generateBigInt(1000)!
//        value2 = GethBigInt(1000000000000000000)! // amountb
        parameter2.append(value2)
        value2 = GethBigInt(1525247790)! //"0x5ae96f2e"
        parameter2.append(value2)
        value2 = GethBigInt(1525334190)! //"0x5aeac0ae"
        parameter2.append(value2)
        value2 = GethBigInt(1980000000000000000)! //0x1B7A5F826F460000
        parameter2.append(value2)
        parameter2.append(UInt8(1))
        parameter2.append(UInt8(50))
        
        // let data = EthFunctionEncoder.default.encodeParameters(parameter2)
        // parameters.append(data.bytes)
        
        // print(parameters)
        
        var newData: Data = Data()
//        parameters.forEach { (param) in
//            newData.append(contentsOf: param)
//        }
        
//        var parameter3: Array<[UInt8]> = Array()
//        parameter3
        
        var datass: Data = Data()
        datass.append(contentsOf: [23, 35, 62, 7, 198, 125, 8, 100, 100, 253, 64, 129, 72, 195, 171, 181, 98, 69, 250, 100])
        datass.append(contentsOf: [131, 17, 128, 68, 38, 162, 68, 149, 189, 67, 6, 218, 245, 245, 149, 164, 67, 165, 46, 50])
        datass.append(contentsOf: [192, 42, 170, 57, 178, 35, 254, 141, 10, 14, 92, 79, 39, 234, 217, 8, 60, 117, 108, 194])
        datass.append(contentsOf: [239, 104, 231, 198, 148, 244, 12, 130, 2, 130, 30, 223, 82, 93, 227, 120, 36, 88, 99, 159])
        datass.append(contentsOf: [185, 64, 101, 72, 42, 214, 77, 76, 43, 146, 82, 53, 141, 116, 107, 57, 232, 32, 165, 130])
        datass.append(contentsOf: [56, 194, 101, 127, 120, 14, 75, 40, 109, 187, 130, 117, 224, 11, 80, 140, 122, 250, 57, 0])
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 205, 228, 57, 216, 52, 224, 0])
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 53, 201, 173, 197, 222, 160, 0, 0])
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 233, 111, 46])
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 234, 192, 174])
        datass.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 122, 95, 130, 111, 70, 0, 0])
        datass.append(contentsOf: [1])
        datass.append(contentsOf: [50])
        
        
//        var parameter4: Array<[UInt8]> = [[23, 35, 62, 7, 198, 125, 8, 100, 100, 253, 64, 129, 72, 195, 171, 181, 98, 69, 250, 100], [131, 17, 128, 68, 38, 162, 68, 149, 189, 67, 6, 218, 245, 245, 149, 164, 67, 165, 46, 50], [192, 42, 170, 57, 178, 35, 254, 141, 10, 14, 92, 79, 39, 234, 217, 8, 60, 117, 108, 194], [239, 104, 231, 198, 148, 244, 12, 130, 2, 130, 30, 223, 82, 93, 227, 120, 36, 88, 99, 159], [185, 64, 101, 72, 42, 214, 77, 76, 43, 146, 82, 53, 141, 116, 107, 57, 232, 32, 165, 130], [56, 194, 101, 127, 120, 14, 75, 40, 109, 187, 130, 117, 224, 11, 80, 140, 122, 250, 57, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 205, 228, 57, 216, 52, 224, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 53, 201, 173, 197, 222, 160, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 233, 111, 46], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 234, 192, 174], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 122, 95, 130, 111, 70, 0, 0], [1], [50]]
//
//        let sdata = Data(parameter4)
        
        
        let SignatureData = web3swift.sign(message: datass)!
        
        print(SignatureData.r)
        print(SignatureData.s)
        print(SignatureData.v)
    }
    
    func testBigValue() {
        let a = PlaceOrderDataManager.shared._encode(1, "LRC")
        print(a)
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
    
}
