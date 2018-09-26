//
//  ExportKeystoreEnterPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SVProgressHUD

class ExportKeystoreEnterPasswordViewController: UIViewController, UITextFieldDelegate {

    var exportWalletInfoType: ExportWalletInfoType = .mnemonic
    var appWallet: AppWallet!
    var keystore: String = ""

    var repeatPasswordTextField: UITextField = UITextField()
    var continueButton: UIButton = UIButton()
    var errorInfoLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Enter Password", comment: "")
        setBackButton()

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        let originY: CGFloat = 80
        let padding: CGFloat = 15
        
        repeatPasswordTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 40)
        
        repeatPasswordTextField.isSecureTextEntry = true
        repeatPasswordTextField.delegate = self
        repeatPasswordTextField.tag = 0
        repeatPasswordTextField.theme_tintColor = GlobalPicker.textColor
        repeatPasswordTextField.theme_textColor = GlobalPicker.textColor
        repeatPasswordTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        repeatPasswordTextField.textAlignment = .center
        repeatPasswordTextField.font = FontConfigManager.shared.getRegularFont(size: 18)
        repeatPasswordTextField.placeholder = LocalizedString("Enter password", comment: "")
        
        repeatPasswordTextField.placeHolderColor = UIColor.text1
        repeatPasswordTextField.contentMode = UIViewContentMode.bottom
        view.addSubview(repeatPasswordTextField)
        
        continueButton.frame = CGRect(x: 48, y: 200, width: screenWidth-48*2, height: 44)
        continueButton.setupSecondary(height: 44)
        continueButton.setTitle(LocalizedString("Confirm", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        view.addSubview(continueButton)
        
        errorInfoLabel.frame = CGRect(x: padding, y: continueButton.bottomY + 40, width: screenWidth-padding*2, height: 17)
        errorInfoLabel.textColor = UIColor.fail
        errorInfoLabel.textAlignment = .center
        errorInfoLabel.alpha = 0.0
        view.addSubview(errorInfoLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        repeatPasswordTextField.becomeFirstResponder()
    }

    @objc func nextButtonPressed(_ sender: Any) {
        print("nextButtonPressed")
        let password = repeatPasswordTextField.text ?? ""

        guard password != "" else {
            self.errorInfoLabel.alpha = 1.0
            self.errorInfoLabel.shake()
            return
        }

        // Only for keystore
        // If a wallet is imported using a private key or mnemonic without passowrd
        if appWallet.setupWalletMethod == .importUsingPrivateKey || (appWallet.setupWalletMethod == .importUsingMnemonic && appWallet.getPassword() == "") {

            var isSucceeded: Bool = false
            SVProgressHUD.show(withStatus: LocalizedString("Exporting keystore", comment: "") + "...")
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let decoder = JSONDecoder()
                    let newkeystoreData: Data = self.appWallet.getKeystore().data(using: .utf8)!
                    let newkeystore = try decoder.decode(NewKeystore.self, from: newkeystoreData)
                    let privateKey = try newkeystore.privateKey(password: self.appWallet.getKeystorePassword())
                    
                    guard let data = Data(hexString: privateKey.toHexString()) else {
                        print("Invalid private key")
                        return // .failure(KeystoreError.failedToImportPrivateKey)
                    }

                    print("Generating keystore")
                    let key = try KeystoreKey(password: password, key: data)
                    print("Finished generating keystore")
                    let keystoreData = try JSONEncoder().encode(key)
                    let json = try JSON(data: keystoreData)
                    self.keystore = json.description

                    isSucceeded = true
                    dispatchGroup.leave()
                } catch {
                    isSucceeded = false
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                SVProgressHUD.dismiss()
                if isSucceeded {
                    // Use this keystore in the view controller.
                    self.pushToExportKeystoreSwipeViewController(keystore: self.keystore)
                } else {
                    let banner = NotificationBanner.generate(title: "Wrong password", style: .danger)
                    banner.duration = 1.5
                    banner.show()
                }
            }

        } else {
            // Validate the password
            var validPassword = true
            if password != appWallet.getPassword() {
                validPassword = false
                self.errorInfoLabel.text = LocalizedString("Wrong password", comment: "")
            }
            
            guard validPassword else {
                self.errorInfoLabel.alpha = 1.0
                self.errorInfoLabel.shake()
                return
            }

            switch exportWalletInfoType {
            case .mnemonic:
                self.pushToBackupMnemonicViewController()
            case .privateKey:
                self.pushToDisplayPrivateKeyViewController()
            case .keystore:
                self.pushToExportKeystoreSwipeViewController(keystore: self.appWallet.getKeystore())
            }

        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if repeatPasswordTextField.isFirstResponder == true {
            repeatPasswordTextField.placeholder = ""
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorInfoLabel.alpha = 0.0
        errorInfoLabel.text = ""
        return true
    }
    
    func pushToBackupMnemonicViewController() {
        // Ask for device password
        AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to access your mnemonic", comment: "")) { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            let viewController = BackupMnemonicViewController()
            viewController.hideButtons = true
            viewController.mnemonics = self.appWallet.mnemonics
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func pushToDisplayPrivateKeyViewController() {
        // Ask for device password
        AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to access your private key", comment: "")) { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            let viewController = DisplayPrivateKeyViewController()
            var isSucceeded: Bool = false
            SVProgressHUD.show(withStatus: LocalizedString("Exporting private key", comment: "") + "...")
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let decoder = JSONDecoder()
                    let newkeystoreData: Data = self.appWallet.getKeystore().data(using: .utf8)!
                    let newkeystore = try decoder.decode(NewKeystore.self, from: newkeystoreData)
                    let privateKey = try newkeystore.privateKey(password: self.appWallet.getKeystorePassword())
                    viewController.displayValue = privateKey.toHexString()
                    
                    isSucceeded = true
                    dispatchGroup.leave()
                } catch {
                    isSucceeded = false
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                SVProgressHUD.dismiss()
                if isSucceeded {
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    let banner = NotificationBanner.generate(title: "Wrong password", style: .danger)
                    banner.duration = 1.5
                    banner.show()
                }
            }
            
        }
    }

    func pushToExportKeystoreSwipeViewController(keystore: String) {
        AuthenticationDataManager.shared.authenticate(reason: LocalizedString("Authenticate to access your keystore", comment: "")) { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            let viewController = ExportKeystoreSwipeViewController()
            viewController.keystore = keystore
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
