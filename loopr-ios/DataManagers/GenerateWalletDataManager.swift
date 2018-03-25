//
//  GenerateWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class GenerateWalletDataManager {
    
    static let shared = GenerateWalletDataManager()
    
    var walletName: String = ""
    var password: String = ""

    private var mnemonic: [String] = []

    // Used in the verification.
    private var userInputMnemonic: [String] = []

    private init() {
        
    }

    func new() -> [String] {
        let mnemonicString = Mnemonic.generate(strength: 256)
        let mnemonic = mnemonicString.components(separatedBy: " ")
        self.mnemonic = mnemonic
        return mnemonic
    }

    func setWalletName(_ walletName: String) {
        self.walletName = walletName
    }
    
    func getMnemonic() -> [String] {
        return mnemonic
    }

    func verify() -> Bool {
        guard mnemonic.count == 24 else {
            return false
        }
        
        guard userInputMnemonic.count == 24 else {
            return false
        }

        for i in 0..<24 {
            guard mnemonic[i] == userInputMnemonic[i] else {
                return false
            }
        }
        
        return true
    }

    // TODO: use error handling
    func complete() -> AppWallet {
        let appWallet = AppWalletDataManager.shared.addWallet(walletName: walletName, mnemonic: mnemonic)
        
        walletName = ""
        mnemonic = []
        userInputMnemonic = []
    
        // TODO: remove the force wrap
        return appWallet!
    }
}
