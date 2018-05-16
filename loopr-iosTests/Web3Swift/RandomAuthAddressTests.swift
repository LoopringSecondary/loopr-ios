//
//  SignRandomAuthAddressTests.swift
//  loopr-iosTests
//
//  Created by xiaoruby on 5/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import XCTest
import Geth
@testable import loopr_ios

class SignRandomAuthAddressTests: XCTestCase {
    
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
        
        // Need to call this one just before sign
        gethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: wallet!.getPassword())
        
        print("current address: \(gethAccount!.getAddress().getHex())")
        let end = Date()
        let timeInterval: Double = end.timeIntervalSince(start)
        print("Time to _keystore: \(timeInterval) seconds")
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateKeystoreFromPrivateKey() {
        let password = "123456"
        let (privateKey, address) = Wallet.generateRandomWallet()
        
        /*
        let appWallet = AppWallet(setupWalletMethod: .importUsingPrivateKey, address: address, privateKey: privateKey, password: password, name: "RandomWallet", active: true)
        print(appWallet.getKeystore())
        */
        
        // Generate keystore data. Note that: this is slow in the debug mode, however it's fast in the release mode.
        let data = Data(hexString: privateKey)!
        let key = try! KeystoreKey(password: password, key: data)
        let keystoreData = try! JSONEncoder().encode(key)
        let json = try! JSON(data: keystoreData)
        let keystoreStringValue = json.description
        print(keystoreStringValue)
    }
    
   
    func testInitEthAccountCoordinatorFromKeystore() {
        let password = "123456"
        let (privateKey, address) = Wallet.generateRandomWallet()
        print(privateKey)
        
        // Generate keystore data. Note that: this is slow in the debug mode, however it's fast in the release mode.
        let data = Data(hexString: privateKey)!
        let key = try! KeystoreKey(password: password, key: data)
        let keystoreData = try! JSONEncoder().encode(key)
        let json = try! JSON(data: keystoreData)
        let keystoreStringValue = json.description
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
        
        // Need to call this one just before sign
        guard let gethAccount: GethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: password) else {
            print("Failed to init EthAccountCoordinator")
            XCTFail()
            return
        }
        
        print("current address: \(gethAccount.getAddress().getHex())")
        XCTAssertEqual(address, gethAccount.getAddress().getHex()!)
        
        let signature = web3swift.sign(message: Data())!
        print("signature v: \(signature.v), r: \(signature.r), s: \(signature.s)")
    }

    
}
