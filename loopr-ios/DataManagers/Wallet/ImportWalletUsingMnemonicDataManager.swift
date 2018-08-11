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
    var derivationPathValue = "m/44'/60'/0'/0"
    var selectedKey: Int = 0
    var addresses: [Address] = []
    
    var walletName: String = ""
    
    private init() {
        
    }
    
    func reset() {
        
    }
    
    func isMnemonicValid(mnemonic: String) -> Bool {
        return Mnemonic.isValid(mnemonic)
    }
    
    func generateAddresses() {
        selectedKey = 0
        addresses.removeAll()
        
        // append "/x"
        let pathValue = derivationPathValue + "/x"
        
        let wallet = Wallet(mnemonic: mnemonic, password: password, path: pathValue)
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
