//
//  Wallet.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

class AppWallet: NSObject, NSCoding {
    
    final let setupWalletMethod: QRCodeMethod

    final let address: String
    final let privateKey: String

    // The password used to get the address and the private key
    // when users use mnemonics and keystore.
    // At the same time, generating a keystore requires password.
    // However, importing a wallet using private key doesn't require password.
    // Use a default password
    // At this usecase, users won't export keystore
    private final var password: String
    
    final var mnemonics: [String]
    private var keystoreString: String?
    
    // TODO: For some reaons, we couldn't reuse it. Improve in the future.
    private var gethKeystoreObject: GethKeyStore?

    // Only used when the wallet is imported using a private key
    private final let keystorePassword: String = "123456"

    // The wallet name in the app. Users can update later.
    var name: String
    
    // If a wallet is created in the app and the user skip the verification,
    // isVerified is false
    var isVerified: Bool

    // TODO: what is active for? Deprecated.
    var active: Bool
    
    var totalCurrency: Double = 0
    var assetSequence: [String] = []
    var assetSequenceInHideSmallAssets: [String] = []
    
    init(setupWalletMethod: QRCodeMethod, address: String, privateKey: String, password: String, mnemonics: [String] = [], keystoreString: String? = nil, name: String, isVerified: Bool, active: Bool, totalCurrency: Double = 0, assetSequence: [String] = [], assetSequenceInHideSmallAssets: [String] = []) {
        self.setupWalletMethod = setupWalletMethod
        self.address = address
        self.privateKey = privateKey
        self.password = password
        self.mnemonics = mnemonics
        self.keystoreString = keystoreString
        self.name = name
        self.isVerified = isVerified
        self.active = active
        self.assetSequence = assetSequence
        self.assetSequenceInHideSmallAssets = assetSequenceInHideSmallAssets
        
        super.init()
        
        if keystoreString == nil || keystoreString == "" || !QRCodeMethod.isKeystore(content: keystoreString ?? "") {
            print("Need to generate keystore")
            generateKeystoreInBackground()
        }
    }
    
    func getAssetSequence() -> [String] {
        return assetSequence
    }

    func addAssetSequence(symbol: String) {
        if symbol.trim() != "" && !assetSequence.contains(symbol) {
            assetSequence.append(symbol)
        }
    }

    func getAssetSequenceInHideSmallAssets() -> [String] {
        return assetSequenceInHideSmallAssets
    }

    func addAssetSequenceInHideSmallAssets(symbol: String) {
        if symbol.trim() != "" && !assetSequenceInHideSmallAssets.contains(symbol) {
            assetSequenceInHideSmallAssets.append(symbol)
        }
    }
    
    func generateKeystoreInBackground() {
        // Generate keystore data
        DispatchQueue.global().async {
            guard let data = Data(hexString: self.privateKey) else {
                print("Invalid private key")
                return // .failure(KeystoreError.failedToImportPrivateKey)
            }
            do {
                print("Generating keystore")
                let key = try KeystoreKey(password: self.getPassword(), key: data)
                print("Finished generating keystore")
                let keystoreData = try JSONEncoder().encode(key)
                let json = try JSON(data: keystoreData)
                self.keystoreString = json.description
                
                guard self.keystoreString != nil else {
                    print("Failed to generate keystore")
                    return
                }
                
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
                try self.keystoreString!.write(to: fileURL, atomically: false, encoding: .utf8)
                
                print(keyDirectory.absoluteString)
                let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
                
                self.gethKeystoreObject = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
                
            } catch {
                print("Failed to generate keystore")
            }
        }
    }
    
    func getGethKeystoreObject() -> NSObject? {
        return self.gethKeystoreObject
    }
    
    func setKeystore(keystoreString: String) {
        self.keystoreString = keystoreString
    }

    func getKeystore() -> String {
        return keystoreString ?? "Generating ..."
    }
    
    func getPassword() -> String {
        if setupWalletMethod == .importUsingPrivateKey {
            return keystorePassword
        } else {
            return password
        }
    }
    
    static func == (lhs: AppWallet, rhs: AppWallet) -> Bool {
        return lhs.address == rhs.address && lhs.privateKey == rhs.privateKey
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(setupWalletMethod.rawValue, forKey: "setupWalletMethod")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(isVerified, forKey: "isVerified")
        aCoder.encode(active, forKey: "active")
        aCoder.encode(mnemonics, forKey: "mnemonics")
        aCoder.encode(keystoreString ?? "", forKey: "keystore")
        aCoder.encode(assetSequence, forKey: "assetSequence")
        aCoder.encode(assetSequenceInHideSmallAssets, forKey: "assetSequenceInHideSmallAssets")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let setupWalletMethodString = aDecoder.decodeObject(forKey: "setupWalletMethod") as? String ?? ""
        
        // If setupWalletMethod is null, the default value is importUsingPrivateKey
        let setupWalletMethod = QRCodeMethod(rawValue: setupWalletMethodString) ?? QRCodeMethod.importUsingPrivateKey
        
        let password = aDecoder.decodeObject(forKey: "password") as? String
        let address = aDecoder.decodeObject(forKey: "address") as? String
        let privateKey = aDecoder.decodeObject(forKey: "privateKey") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let isVerified = aDecoder.containsValue(forKey: "isVerified") ? aDecoder.decodeBool(forKey: "isVerified") : false
        let active = aDecoder.decodeBool(forKey: "active")
        
        // TODO: mnemonics vs. mnemonic
        let mnemonics = aDecoder.decodeObject(forKey: "mnemonics") as? [String]
        
        let keystoreString = aDecoder.decodeObject(forKey: "keystore") as? String
        
        let assetSequence = aDecoder.decodeObject(forKey: "assetSequence") as? [String] ?? []
        let filteredAssetSequence = assetSequence.filter { (item) -> Bool in
            return item.trim() != ""
        }

        let assetSequenceInHideSmallAssets = aDecoder.decodeObject(forKey: "assetSequenceInHideSmallAssets") as? [String] ?? []
        let filteredAssetSequenceInHideSmallAssets = assetSequenceInHideSmallAssets.filter { (item) -> Bool in
            return item.trim() != ""
        }
        
        if let address = address, let privateKey = privateKey, let password = password, let mnemonics = mnemonics, let name = name {
            self.init(setupWalletMethod: setupWalletMethod, address: address, privateKey: privateKey, password: password, mnemonics: mnemonics, keystoreString: keystoreString, name: name, isVerified: isVerified, active: active, assetSequence: unique(filteredAssetSequence), assetSequenceInHideSmallAssets: unique(filteredAssetSequenceInHideSmallAssets))
        } else {
            return nil
        }
    }

}
