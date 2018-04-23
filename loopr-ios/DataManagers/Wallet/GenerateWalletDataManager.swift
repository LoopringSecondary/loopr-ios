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

    var mnemonicQuestions: [MnemonicQuestion] = []

    private init() {
        
    }

    // Generate a new wallet and store mnemonic in the memory.
    func new() -> [String] {
        let mnemonicString = Mnemonic.generate(strength: 256)
        let mnemonics = mnemonicString.components(separatedBy: " ")
        self.mnemonics = mnemonics

        // Generate 24 questions
        mnemonicQuestions = []
        for (index, value) in mnemonics.enumerated() {
            let mnemonicQuestion = MnemonicQuestion(index: index, mnemonic: value)
            mnemonicQuestions.append(mnemonicQuestion)
        }

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

    // TODO: In the design, users can only move to the next question?
    func getQuestion(index: Int) -> MnemonicQuestion {
        if index >= mnemonicQuestions.count {
            return mnemonicQuestions[0]
        }
        return mnemonicQuestions[index]
    }

    func verify() -> Bool {
        guard mnemonics.count == 24 else {
            return false
        }
        
        guard userInputMnemonics.count == 24 else {
            return false
        }

        for i in 0..<24 {
            guard mnemonics[i] == userInputMnemonics[i] else {
                return false
            }
        }
        
        return true
    }

    // TODO: use error handling
    func complete() -> AppWallet {
        let appWallet = AppWalletDataManager.shared.addWallet(walletName: walletName, mnemonics: mnemonics, password: password, derivationPath: "m/44'/60'/0'/0/x", key: 0)

        // Reset
        walletName = ""
        password = ""
        mnemonics = []
        userInputMnemonics = []
    
        // TODO: remove the force wrap
        return appWallet!
    }
}
