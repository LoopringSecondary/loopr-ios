//
//  Wallet.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class AppWallet: NSObject, NSCoding {

    final let address: String
    final let privateKey: String

    // The password used to get the address and the private key when users use mnemonics and keystore.
    final let password: String
    final var mnemonics: [String]
    var keystoreData: Data = Data()

    // The wallet name in the app. Users can update later.
    var name: String

    // TODO: what is active for?
    var active: Bool

    var assetSequence: [String] = []
    var assetSequenceInHideSmallAssets: [String] = []
    
    init(address: String, privateKey: String, password: String, mnemonics: [String] = [], name: String, active: Bool, assetSequence: [String] = ["ETH", "LRC"], assetSequenceInHideSmallAssets: [String] = ["ETH", "LRC"]) {
        self.address = address
        self.privateKey = privateKey

        self.password = password
        self.mnemonics = mnemonics

        self.name = name
        self.active = active

        // Generate keystore data
        /*
        guard let data = Data(hexString: privateKey) else {
            return // .failure(KeystoreError.failedToImportPrivateKey)
        }
        do {
            let key = try KeystoreKey(password: "password", key: data)
            keystoreData = try JSONEncoder().encode(key)
        } catch {
            
        }
        */

        self.assetSequence = assetSequence
        self.assetSequenceInHideSmallAssets = assetSequenceInHideSmallAssets
    }
    
    func getKeystore() -> JSON {
        // TODO: catch error
        let data = Data(hexString: privateKey)!
        let key = try! KeystoreKey(password: password, key: data)
        keystoreData = try! JSONEncoder().encode(key)
        let json = try! JSON(data: keystoreData)
        return json
    }
    
    static func == (lhs: AppWallet, rhs: AppWallet) -> Bool {
        return lhs.address == rhs.address && lhs.privateKey == rhs.privateKey
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(password, forKey: "password")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(active, forKey: "active")
        aCoder.encode(mnemonics, forKey: "mnemonics")
        aCoder.encode(assetSequence, forKey: "assetSequence")
        aCoder.encode(assetSequenceInHideSmallAssets, forKey: "assetSequenceInHideSmallAssets")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let password = aDecoder.decodeObject(forKey: "password") as? String
        let address = aDecoder.decodeObject(forKey: "address") as? String
        let privateKey = aDecoder.decodeObject(forKey: "privateKey") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let active = aDecoder.decodeBool(forKey: "active")

        // TODO: mnemonics vs. mnemonic
        let mnemonics = aDecoder.decodeObject(forKey: "mnemonics") as? [String]
        let assetSequence = aDecoder.decodeObject(forKey: "assetSequence") as? [String] ?? []
        let assetSequenceInHideSmallAssets = aDecoder.decodeObject(forKey: "assetSequenceInHideSmallAssets") as? [String] ?? []
        
        if let address = address, let privateKey = privateKey, let password = password, let mnemonics = mnemonics, let name = name {
            self.init(address: address, privateKey: privateKey, password: password, mnemonics: mnemonics, name: name, active: active, assetSequence: unique(assetSequence), assetSequenceInHideSmallAssets: unique(assetSequenceInHideSmallAssets))
        } else {
            return nil
        }
    }
}
