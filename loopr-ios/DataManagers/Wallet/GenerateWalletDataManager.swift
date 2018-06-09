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

    private var mnemonics: [String] = []

    // Used in the verification.
    private var userInputMnemonics: [String] = []

    var isVerified: Bool = false

    private init() {
        
    }

    // Generate a new wallet and store mnemonic in the memory.
    func new() -> [String] {
        let mnemonicString = Mnemonic.generate(strength: 128)
        let mnemonics = mnemonicString.components(separatedBy: " ")
        self.mnemonics = mnemonics
        return mnemonics
    }

    func setWalletName(_ walletName: String) {
        self.walletName = walletName
    }
    
    func setPassword(_ password: String) {
        self.password = password
    }
    
    func getMnemonics() -> [String] {
        return mnemonics
    }
    
    func getUserInputMnemonics() -> [String] {
        return userInputMnemonics
    }

    func clearUserInputMnemonic() {
        userInputMnemonics = []
    }
    
    func addUserInputMnemonic(mnemonic: String) {
        userInputMnemonics.append(mnemonic)
    }
    
    func undoLastUserInputMnemonic() {
        _ = userInputMnemonics.popLast()
    }

    func verify() -> Bool {
        guard mnemonics.count == userInputMnemonics.count else {
            isVerified = false
            return false
        }

        for i in 0..<mnemonics.count {
            guard mnemonics[i] == userInputMnemonics[i] else {
                isVerified = false
                return false
            }
        }
        
        isVerified = true
        return true
    }

    // TODO: use error handling
    func complete() throws -> AppWallet {
        print("Verify mnemonics: \(isVerified)")
        let appWallet = try AppWalletDataManager.shared.addWallet(setupWalletMethod: .create, walletName: walletName, mnemonics: mnemonics, password: password, derivationPath: "m/44'/60'/0'/0/x", key: 0, isVerified: isVerified)

        // Reset
        walletName = ""
        password = ""
        mnemonics = []
        userInputMnemonics = []
        isVerified = false

        // Inform relay
        LoopringAPIRequest.unlockWallet(owner: appWallet.address) { (_, _) in }
        
        return appWallet
    }
}
