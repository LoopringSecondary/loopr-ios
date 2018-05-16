//
//  SignHashTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 5/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios

class SignHashTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func signHash(privateKey: String, hash: Data) -> SignatureData? {
        let password = "123456"
        
        // Generate keystore data. Note that: this is slow in the debug mode, however it's fast in the release mode.
        let data = Data(hexString: privateKey)!
        let key = try! KeystoreKey(password: password, key: data)
        let keystoreData = try! JSONEncoder().encode(key)
        let json = try! JSON(data: keystoreData)
        let keystoreStringValue = json.description
        print(keystoreStringValue)
        
        // Create key directory
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("signHash")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("signHash")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory)
        
        // Save the keystore string value to keyDirectory
        let fileURL = keyDirectory.appendingPathComponent("key.json")
        try! keystoreStringValue.write(to: fileURL, atomically: false, encoding: .utf8)
        
        print(keyDirectory.absoluteString)
        let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
        
        let gethKeystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
        
        // Need to call this one just before sign
        guard let gethAccount: GethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: password) else {
            print("Failed to init EthAccountCoordinator")
            return nil
        }
        print("current address: \(gethAccount.getAddress().getHex())")
        

        let signature = web3swift.sign(message: hash)!
        return signature
    }
    
    func testSignHashFunction() {
        let address = "0x8cA5fD265499F430a86B34dF241476638C6e08a6"
        let privateKey = "78ba6d34d50fe01acabd5f1480d4c0b5613da044a9f53a027f67f780756c74d5"
        let hashData = "hello world".data(using: .utf8)!

        let signatureData = signHash(privateKey: privateKey, hash: hashData)
        XCTAssertNotNil(signatureData)
        print("signature v: \(signatureData!.v), r: \(signatureData!.r), s: \(signatureData!.s)")
    }

}
