//
//  GenerateWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletViewController: UIViewController, UITextFieldDelegate {
    
    var setupWalletMethod: SetupWalletMethod = .create

    // Scrollable UI components
    var walletNameTextField: UITextField = UITextField()
    var walletNameUnderLine: UIView = UIView()
    var walletNameInfoLabel: UILabel = UILabel()
    
    var walletPasswordTextField: UITextField = UITextField()
    var walletPasswordUnderLine: UIView = UIView()
    var walletPasswordInfoLabel: UILabel = UILabel()
    
    var walletRepeatPasswordTextField: UITextField = UITextField()
    var walletRepeatPasswordUnderLine: UIView = UIView()
    var walletRepeatPasswordInfoLabel: UILabel = UILabel()
    
    var continueButton: UIButton = UIButton()
    
    // Keyboard
    var isKeyboardShown: Bool = false
    var keyboardOffsetY: CGFloat = 0
    
    convenience init(setupWalletMethod: SetupWalletMethod) {
        self.init(nibName: "GenerateWalletViewController", bundle: nil)
        self.setupWalletMethod = setupWalletMethod
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Generate Wallet", comment: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        
        setBackButton()
        
        self.navigationController?.isNavigationBarHidden = false
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15

        walletNameTextField.delegate = self
        walletNameTextField.tag = 0
        // walletNameTextField.inputView = UIView()
        walletNameTextField.theme_tintColor = GlobalPicker.textColor
        walletNameTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletNameTextField.placeholder = NSLocalizedString("Give your wallet an awesome name", comment: "")
        walletNameTextField.contentMode = UIViewContentMode.bottom
        walletNameTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletNameTextField)
        
        walletNameUnderLine.frame = CGRect(x: padding, y: walletNameTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletNameUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(walletNameUnderLine)
        
        walletNameInfoLabel.frame = CGRect(x: padding, y: walletNameUnderLine.frame.maxY + 9, width: screenWidth - padding * 2, height: 16)
        walletNameInfoLabel.text = NSLocalizedString("Please enter a wallet name", comment: "")
        walletNameInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        walletNameInfoLabel.textColor = UIStyleConfig.red
        walletNameInfoLabel.alpha = 0.0
        view.addSubview(walletNameInfoLabel)
        
        walletPasswordTextField.isSecureTextEntry = true
        walletPasswordTextField.delegate = self
        walletPasswordTextField.tag = 1
        // walletPasswordTextField.inputView = UIView()
        walletPasswordTextField.theme_tintColor = GlobalPicker.textColor
        walletPasswordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletPasswordTextField.placeholder = NSLocalizedString("Password", comment: "")
        walletPasswordTextField.contentMode = UIViewContentMode.bottom
        walletPasswordTextField.frame = CGRect(x: padding, y: walletNameUnderLine.frame.maxY + 45, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletPasswordTextField)
        
        walletPasswordUnderLine.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletPasswordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(walletPasswordUnderLine)
        
        walletPasswordInfoLabel.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY + 9, width: screenWidth - padding * 2, height: 16)
        walletPasswordInfoLabel.text = NSLocalizedString("Please set a password", comment: "")
        walletPasswordInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        walletPasswordInfoLabel.textColor = UIStyleConfig.red
        walletPasswordInfoLabel.alpha = 0.0
        view.addSubview(walletPasswordInfoLabel)
        
        // Repeat password
        walletRepeatPasswordTextField.isSecureTextEntry = true
        walletRepeatPasswordTextField.delegate = self
        walletRepeatPasswordTextField.tag = 2
        // walletPasswordTextField.inputView = UIView()
        walletRepeatPasswordTextField.theme_tintColor = GlobalPicker.textColor
        walletRepeatPasswordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletRepeatPasswordTextField.placeholder = NSLocalizedString("Confirm password", comment: "")
        walletRepeatPasswordTextField.contentMode = UIViewContentMode.bottom
        walletRepeatPasswordTextField.frame = CGRect(x: padding, y: walletPasswordUnderLine.frame.maxY + 45, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletRepeatPasswordTextField)
        
        walletRepeatPasswordUnderLine.frame = CGRect(x: padding, y: walletRepeatPasswordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletRepeatPasswordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(walletRepeatPasswordUnderLine)
        
        walletRepeatPasswordInfoLabel.frame = CGRect(x: padding, y: walletRepeatPasswordTextField.frame.maxY + 9, width: screenWidth - padding * 2, height: 16)
        walletRepeatPasswordInfoLabel.text = NSLocalizedString("Confirm your password", comment: "")
        walletRepeatPasswordInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        walletRepeatPasswordInfoLabel.textColor = UIStyleConfig.red
        walletRepeatPasswordInfoLabel.alpha = 0.0
        view.addSubview(walletRepeatPasswordInfoLabel)
        
        continueButton.setupRoundBlack()
        continueButton.frame = CGRect(x: padding, y: walletRepeatPasswordUnderLine.frame.maxY + 50, width: screenWidth - padding * 2, height: 47)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // UI will be different based on SetupWalletMethod
        if setupWalletMethod == .create {
            self.navigationItem.title = NSLocalizedString("Create a new wallet", comment: "")
            continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
            
            // Generate a new wallet
            _ = GenerateWalletDataManager.shared.new()
            
        } else {
            walletPasswordTextField.isHidden = true
            walletPasswordUnderLine.isHidden = true
            self.navigationItem.title = NSLocalizedString("Setup the wallet name", comment: "")
            continueButton.setTitle(NSLocalizedString("Enter Wallet", comment: ""), for: .normal)
        }
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(scrollViewTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    @objc func pressedContinueButton(_ sender: Any) {
        print("pressedContinueButton")
        
        guard AppWalletDataManager.shared.isNewWalletNameToken(newWalletname: walletNameTextField.text ?? "") else {
            let title = NSLocalizedString("The name is token, please try another one", comment: "")
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        switch setupWalletMethod {
        case .create:
            pressedContinueButtonInCreate()
            
        case .importUsingMnemonic:
            if !pressedContinueButtonInImport() {
                return
            }
            walletNameTextField.resignFirstResponder()
            ImportWalletUsingMnemonicDataManager.shared.walletName = walletNameTextField.text ?? ""
            try! ImportWalletUsingMnemonicDataManager.shared.complete()
            
        case .importUsingKeystore:
            if !pressedContinueButtonInImport() {
                return
            }
            walletNameTextField.resignFirstResponder()
            ImportWalletUsingKeystoreDataManager.shared.walletName = walletNameTextField.text ?? ""
            try! ImportWalletUsingKeystoreDataManager.shared.complete()
            
        case .importUsingPrivateKey:
            if !pressedContinueButtonInImport() {
                return
            }
            walletNameTextField.resignFirstResponder()
            ImportWalletUsingPrivateKeyDataManager.shared.walletName = walletNameTextField.text ?? ""
            try! ImportWalletUsingPrivateKeyDataManager.shared.complete()
        }
        
        if setupWalletMethod == .create {
            
        } else {
            // Exit the whole importing process
            if SetupDataManager.shared.hasPresented {
                self.dismiss(animated: true, completion: {
                    
                })
            } else {
                SetupDataManager.shared.hasPresented = true
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            }
        }
    }
    
    func pressedContinueButtonInCreate() {
        var validWalletName = true
        var validPassword = true
        var validRepeatPassword = true
        
        let walletName = walletNameTextField.text ?? ""
        if walletName.trim() == "" {
            validWalletName = false
            self.walletNameInfoLabel.shake()
            self.walletNameInfoLabel.alpha = 1.0
        }
        
        let password = walletPasswordTextField.text ?? ""
        if password.trim() == "" {
            validPassword = false
            self.walletPasswordInfoLabel.shake()
            self.walletPasswordInfoLabel.alpha = 1.0
        }
        
        let repeatPassword = walletRepeatPasswordTextField.text ?? ""
        if repeatPassword.trim() == "" {
            validRepeatPassword = false
        }
        if password != repeatPassword {
            validRepeatPassword = false
            self.walletRepeatPasswordInfoLabel.text = NSLocalizedString("Please input the consistant password.", comment: "")
        }
        if !validRepeatPassword {
            self.walletRepeatPasswordInfoLabel.shake()
            self.walletRepeatPasswordInfoLabel.alpha = 1.0
        }
        
        if validWalletName && validPassword && validRepeatPassword {
            GenerateWalletDataManager.shared.setWalletName(walletName)
            GenerateWalletDataManager.shared.setPassword(password)
            // let viewController = GenerateMnemonicViewController()
            let viewController = BackupMnemonicViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func pressedContinueButtonInImport() -> Bool {
        var validWalletName = true
        
        let walletName = walletNameTextField.text ?? ""
        if walletName.trim() == "" {
            validWalletName = false
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                self.walletNameInfoLabel.alpha = 1.0
            }, completion: { (_) in
                
            })
        }
        
        return validWalletName
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.utf16.count)! + (string.utf16.count) - range.length
        print("textField shouldChangeCharactersIn \(newLength)")
        
        switch textField.tag {
        case walletNameTextField.tag:
            if newLength > 0 {
                walletNameInfoLabel.alpha = 0.0
                walletNameUnderLine.backgroundColor = UIColor.black
            } else {
                walletNameUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        case walletPasswordTextField.tag:
            if newLength > 0 {
                walletPasswordInfoLabel.alpha = 0.0
                walletPasswordUnderLine.backgroundColor = UIColor.black
            } else {
                walletPasswordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        case walletRepeatPasswordTextField.tag:
            if newLength > 0 {
                walletRepeatPasswordInfoLabel.alpha = 0.0
                walletRepeatPasswordUnderLine.backgroundColor = UIColor.black
            } else {
                walletRepeatPasswordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        default: ()
        }
        return true
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        
        // Hide the keyboard and adjust the position
        walletNameTextField.resignFirstResponder()
        walletPasswordTextField.resignFirstResponder()
        
        if isKeyboardShown {
            UIView.animate(withDuration: 0.4, animations: {
                // Wallet Name
                self.walletNameTextField.moveOffset(y: self.keyboardOffsetY)
                self.walletNameUnderLine.moveOffset(y: self.keyboardOffsetY)
                self.walletNameInfoLabel.moveOffset(y: self.keyboardOffsetY)
                
                // Wallet Password
                self.walletPasswordTextField.moveOffset(y: self.keyboardOffsetY)
                self.walletPasswordUnderLine.moveOffset(y: self.keyboardOffsetY)
                self.walletPasswordInfoLabel.moveOffset(y: self.keyboardOffsetY)
                
                // continueButton
                self.continueButton.moveOffset(y: self.keyboardOffsetY)
            })
            isKeyboardShown = false
        }
    }
    
    @objc func systemKeyboardWillShow(_ notification: Notification) {
        if !isKeyboardShown {
            guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                let keyboardMinY = self.view.frame.height - keyboardHeight - bottomPadding
                
                keyboardOffsetY = (continueButton.frame.maxY + 20.0) - keyboardMinY

                if keyboardOffsetY > 0 {
                    UIView.animate(withDuration: 1.0, animations: {
                        // Wallet Name
                        self.walletNameTextField.moveOffset(y: -self.keyboardOffsetY)
                        self.walletNameUnderLine.moveOffset(y: -self.keyboardOffsetY)
                        self.walletNameInfoLabel.moveOffset(y: -self.keyboardOffsetY)
                        
                        // Wallet Password
                        self.walletPasswordTextField.moveOffset(y: -self.keyboardOffsetY)
                        self.walletPasswordUnderLine.moveOffset(y: -self.keyboardOffsetY)
                        self.walletPasswordInfoLabel.moveOffset(y: -self.keyboardOffsetY)
                        
                        // continueButton
                        self.continueButton.moveOffset(y: -self.keyboardOffsetY)
                    })
                    
                    isKeyboardShown = true
                }
            } else {
                
            }
        }
    }
    
    @objc func systemKeyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
    }
}
