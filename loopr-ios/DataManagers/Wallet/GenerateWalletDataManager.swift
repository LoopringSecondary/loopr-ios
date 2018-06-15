//
//  GenerateWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SVProgressHUD

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
    func new() {
        let mnemonicString = Mnemonic.generate(strength: 128)
        let mnemonics = mnemonicString.components(separatedBy: " ")
        self.mnemonics = mnemonics
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

    func complete(completion: @escaping (_ appWallet: AppWallet?, _ error: AddWalletError?) -> Void) {
        print("Verify mnemonics: \(isVerified)")
        SVProgressHUD.show(withStatus: NSLocalizedString("Initializing the wallet", comment: "") + "...")
        DispatchQueue.global().async {
            AppWalletDataManager.shared.addWallet(setupWalletMethod: .create, walletName: self.walletName, mnemonics: self.mnemonics, password: self.password, derivationPath: "m/44'/60'/0'/0/x", key: 0, isVerified: self.isVerified, completionHandler: {(appWallet, error) in
                
                // Reset
                self.walletName = ""
                self.password = ""
                self.mnemonics = []
                self.userInputMnemonics = []
                self.isVerified = false
                
                // Inform relay
                LoopringAPIRequest.unlockWallet(owner: appWallet!.address) { (_, _) in }
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    completion(appWallet, error)
                }
            })
        }
    }
}
