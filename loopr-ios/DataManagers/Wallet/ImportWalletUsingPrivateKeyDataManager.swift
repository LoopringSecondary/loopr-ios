//
//  ImportWalletUsingPrivateKeyDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/19/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import secp256k1_ios
import SVProgressHUD
import NotificationBannerSwift

class ImportWalletUsingPrivateKeyDataManager: ImportWalletProtocol {
    
    static let shared = ImportWalletUsingPrivateKeyDataManager()
    
    var walletName: String

    var devicePassword: String = ""
    
    var address: String
    private var privateKey: String
    private var keystore: String
    
    private init() {
        walletName = ""
        address = ""
        privateKey = ""
        keystore = ""
    }
    
    func reset() {
        walletName = ""
        address = ""
        privateKey = ""
        keystore = ""
    }

    func importWallet(privateKey privateKeyString: String) throws {
        print("Start to unlock a new wallet using the private key")
        let privateKeyData: Data? = Data(hexString: privateKeyString.trim())
        guard privateKeyData != nil else {
            print("Invalid private key")
            throw ImportWalletError.invalidPrivateKey
        }
        
        // Store private key
        privateKey = privateKeyString.trim()
        
        // TODO: move this part to sdk?
        let pubKey = Secp256k1.shared.pubicKey(from: privateKeyData!)
        let keystoreAddress = KeystoreKey.decodeAddress(from: pubKey)
        
        // Store public key
        address = keystoreAddress.eip55String
    }

    func complete(completion: @escaping (_ appWallet: AppWallet?, _ error: AddWalletError?) -> Void) {
        if AppWalletDataManager.shared.isDuplicatedAddress(address: address) {
            completion(nil, AddWalletError.duplicatedAddress)
        }
        
        SVProgressHUD.show(withStatus: LocalizedString("Initializing the wallet", comment: "") + "...")
        DispatchQueue.global().async {
            do {
                guard let data = Data(hexString: self.privateKey) else {
                    print("Invalid private key")
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        completion(nil, AddWalletError.invalidInput)
                    }
                    return
                }
                
                print("Generating keystore")
                let key = try KeystoreKey(password: self.devicePassword, key: data)
                print("Finished generating keystore")
                let keystoreData = try JSONEncoder().encode(key)
                let json = try JSON(data: keystoreData)
                self.keystore = json.description
                
                let newAppWallet = AppWallet(setupWalletMethod: .importUsingPrivateKey, address: self.address, password: "", devicePassword: self.devicePassword, keystoreString: self.keystore, name: self.walletName.trim(), isVerified: true, tokenList: ["ETH", "WETH", "LRC"], manuallyDisabledTokenList: [])
                AppWalletDataManager.shared.updateAppWalletsInLocalStorage(newAppWallet: newAppWallet)
                CurrentAppWalletDataManager.shared.setCurrentAppWallet(newAppWallet, completionHandler: {})
                
                // Inform relay
                LoopringAPIRequest.unlockWallet(owner: self.address) { (_, _) in }
                print("Finished unlocking a new wallet in ImportWalletUsingPrivateKeyDataManager")

                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    completion(newAppWallet, nil)
                }

            } catch {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    completion(nil, AddWalletError.invalidInput)
                }
            }
        }
    }
}
