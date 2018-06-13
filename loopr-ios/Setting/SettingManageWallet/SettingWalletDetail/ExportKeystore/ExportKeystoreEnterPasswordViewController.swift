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

    var appWallet: AppWallet!
    var keystore: String = ""

    var titleLabel: UILabel =  UILabel()

    var passwordTextField: UITextField = UITextField()
    var passwordUnderLine: UIView = UIView()
    var passwordInfoLabel: UILabel = UILabel()
    var nextButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Enter password", comment: "")
        view.addSubview(titleLabel)
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.tag = 1
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        passwordTextField.placeholder = ""
        passwordTextField.contentMode = UIViewContentMode.bottom
        passwordTextField.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 30, width: screenWidth-padding*2, height: 40)
        view.addSubview(passwordTextField)
        
        passwordUnderLine.frame = CGRect(x: padding, y: passwordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        passwordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(passwordUnderLine)
        
        passwordInfoLabel.frame = CGRect(x: padding, y: passwordTextField.frame.maxY + 9, width: screenWidth - padding * 2, height: 16)
        passwordInfoLabel.text = NSLocalizedString("Wrong password", comment: "")
        passwordInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        passwordInfoLabel.textColor = UIStyleConfig.red
        passwordInfoLabel.alpha = 0.0
        view.addSubview(passwordInfoLabel)

        nextButton.title = NSLocalizedString("Next", comment: "")
        nextButton.setupRoundBlack()
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        nextButton.frame = CGRect(x: padding, y: passwordInfoLabel.frame.maxY + 40, width: screenWidth - padding * 2, height: 47)
        view.addSubview(nextButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.becomeFirstResponder()
    }

    @objc func nextButtonPressed(_ sender: Any) {
        print("nextButtonPressed")
        let password = passwordTextField.text ?? ""

        guard password != "" else {
            self.passwordInfoLabel.text = NSLocalizedString("Please enter a password", comment: "")
            self.passwordInfoLabel.alpha = 1.0
            self.passwordInfoLabel.shake()
            return
        }
        
        if appWallet.setupWalletMethod == .importUsingPrivateKey || (appWallet.setupWalletMethod == .importUsingMnemonic && appWallet.getPassword() == "") {
            var isSucceeded: Bool = false
            SVProgressHUD.show(withStatus: NSLocalizedString("Exporting keystore", comment: "") + "...")
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    guard let data = Data(hexString: self.appWallet.privateKey) else {
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
                    let viewController = ExportKeystoreSwipeViewController()
                    viewController.keystore = self.keystore
                    self.navigationController?.pushViewController(viewController, animated: true)
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
                self.passwordInfoLabel.text = NSLocalizedString("Wrong password", comment: "")
            }
            
            guard validPassword else {
                self.passwordInfoLabel.alpha = 1.0
                self.passwordInfoLabel.shake()
                return
            }

            let viewController = ExportKeystoreSwipeViewController()
            viewController.keystore = appWallet.getKeystore()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.utf16.count)! + (string.utf16.count) - range.length
        print("textField shouldChangeCharactersIn \(newLength)")
        
        switch textField.tag {
        case passwordTextField.tag:
            if newLength > 0 {
                passwordInfoLabel.alpha = 0.0
                passwordUnderLine.backgroundColor = UIColor.black
            } else {
                passwordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        default: ()
        }
        return true
    }

}
