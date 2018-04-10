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

    final let name: String
    final let active: Bool

    var mnemonics: [String] = []
    var keystoreValue: String = ""
    
    init(address: String, privateKey: String, name: String, active: Bool, mnemonics: [String] = [], keystoreValue: String = "") {
        self.address = address
        self.privateKey = privateKey
        self.name = name
        self.active = active

        self.mnemonics = mnemonics
        self.keystoreValue = keystoreValue
    }
    
    static func == (lhs: AppWallet, rhs: AppWallet) -> Bool {
        return lhs.address == rhs.address && lhs.privateKey == rhs.privateKey
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(address, forKey: "address")
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(active, forKey: "active")
        
        aCoder.encode(mnemonics, forKey: "mnemonics")
        aCoder.encode(keystoreValue, forKey: "keystore")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let address = aDecoder.decodeObject(forKey: "address") as? String
        let privateKey = aDecoder.decodeObject(forKey: "privateKey") as? String
        
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let active = aDecoder.decodeBool(forKey: "active")

        // TODO: mnemonics vs. mnemonic
        let mnemonics = aDecoder.decodeObject(forKey: "mnemonics") as? [String]
        
        let keystoreValue = aDecoder.decodeObject(forKey: "keystore") as? String

        if let address = address, let privateKey = privateKey, let mnemonics = mnemonics, let keystoreValue = keystoreValue, let name = name {
            self.init(address: address, privateKey: privateKey, name: name, active: active, mnemonics: mnemonics, keystoreValue: keystoreValue)
        } else {
            return nil
        }
    }
}
