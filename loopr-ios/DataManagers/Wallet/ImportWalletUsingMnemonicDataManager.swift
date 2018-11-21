//
//  ImportWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import SVProgressHUD

class ImportWalletUsingMnemonicDataManager: ImportWalletProtocol {
    
    static let shared = ImportWalletUsingMnemonicDataManager()
    
    var mnemonic: String = ""
    var password: String = ""
    private var derivationPathValue = "m/44'/60'/0'/0"
    var selectedKey: Int = 0
    var addresses: [Address] = []
    
    var walletType: WalletType = WalletType.getLoopringWallet()
    
    var walletName: String = ""
    
    private init() {
        
    }
    
    func reset() {
        
    }
    
    func isMnemonicValid(mnemonic: String) -> Bool {
        return Mnemonic.isValid(mnemonic)
    }
    
    func setWalletType(newWalletType: WalletType) {
        self.walletType = newWalletType
        derivationPathValue = walletType.derivationPath
    }
    
    func generateAddresses() {
        selectedKey = 0
        addresses.removeAll()
        
        // append "/x"
        let pathValue = derivationPathValue + "/x"
        let wallet: Wallet
        
        // imToken wallet doesn't use password to get ETH addresses.
        // password won't be changed as users may try different wallet types.
        if walletType == WalletType.getImtokenWallet() {
            wallet = Wallet(mnemonic: mnemonic, password: "", path: pathValue)
        } else {
            wallet = Wallet(mnemonic: mnemonic, password: password, path: pathValue)
        }

        // TODO: in theory, it should generate many many addresses. However, we should only top 100 addresses. Improve in the future.
        for i in 0..<100 {
            let address = wallet.getKey(at: i).address
            addresses.append(address)
        }
    }
    
    func complete(completion: @escaping (_ appWallet: AppWallet?, _ error: AddWalletError?) -> Void) {
        // Append /x to the derivation path
        let pathValue = derivationPathValue + "/x"
        
        SVProgressHUD.show(withStatus: LocalizedString("Initializing the wallet", comment: "") + "...")
        DispatchQueue.global().async {
            
            // imToken wallet doesn't use password to get ETH addresses.
            if self.walletType == WalletType.getImtokenWallet() {
                self.password = ""
            }

            AppWalletDataManager.shared.addWallet(setupWalletMethod: .importUsingMnemonic, walletName: self.walletName, mnemonics: self.mnemonic.components(separatedBy: " "), password: self.password, derivationPath: pathValue, key: self.selectedKey, isVerified: true, completionHandler: {(appWallet, error) in
                if error == nil {
                    // Inform relay
                    LoopringAPIRequest.unlockWallet(owner: appWallet!.address) { (_, _) in }
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    completion(appWallet, error)
                }
            })
        }
    }
}
