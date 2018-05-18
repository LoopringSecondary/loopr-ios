//
//  GenerateWalletConfirmPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/25/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletConfirmPasswordViewController: UIViewController, UITextFieldDelegate {

    var setupWalletMethod: SetupWalletMethod = .create

    var titleLabel: UILabel =  UILabel()
    
    var walletPasswordTextField: UITextField = UITextField()
    var walletPasswordUnderLine: UIView = UIView()
    var walletPasswordInfoLabel: UILabel = UILabel()
    
    var continueButton: UIButton = UIButton()

    // Keyboard
    var isKeyboardShown: Bool = false
    var keyboardOffsetY: CGFloat = 0

    convenience init(setupWalletMethod: SetupWalletMethod) {
        self.init(nibName: "GenerateWalletConfirmPasswordViewController", bundle: nil)
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
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        setBackButton()
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Confirm password", comment: "")
        view.addSubview(titleLabel)
        
        walletPasswordTextField.isSecureTextEntry = true
        walletPasswordTextField.delegate = self
        walletPasswordTextField.tag = 1
        // walletPasswordTextField.inputView = UIView()
        walletPasswordTextField.theme_tintColor = GlobalPicker.textColor
        walletPasswordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletPasswordTextField.placeholder = ""
        walletPasswordTextField.contentMode = UIViewContentMode.bottom
        walletPasswordTextField.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 90, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletPasswordTextField)
        
        walletPasswordUnderLine.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletPasswordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(walletPasswordUnderLine)
        
        walletPasswordInfoLabel.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY + 9, width: screenWidth - padding * 2, height: 16)
        walletPasswordInfoLabel.text = NSLocalizedString("Please enter a password", comment: "")
        walletPasswordInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        walletPasswordInfoLabel.textColor = UIStyleConfig.red
        walletPasswordInfoLabel.alpha = 0.0
        view.addSubview(walletPasswordInfoLabel)
        
        continueButton.setupRoundBlack()
        continueButton.setTitle(NSLocalizedString("Enter Wallet", comment: ""), for: .normal)
        continueButton.frame = CGRect(x: padding, y: walletPasswordUnderLine.frame.maxY + 50, width: screenWidth - padding * 2, height: 47)
        continueButton.addTarget(self, action: #selector(self.pressedContinueButton(_:)), for: .touchUpInside)
        view.addSubview(continueButton)

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(scrollViewTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.utf16.count)! + (string.utf16.count) - range.length
        print("textField shouldChangeCharactersIn \(newLength)")
        
        if textField.tag == walletPasswordTextField.tag {
            if newLength > 0 {
                walletPasswordUnderLine.backgroundColor = UIColor.black
            } else {
                walletPasswordUnderLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        }
        return true
    }

    @IBAction func pressedContinueButton(_ sender: Any) {
        print("pressedContinueButton")
        
        var validPassword = true
        
        let password = walletPasswordTextField.text ?? ""
        if password.trim() == "" {
            validPassword = false
            self.walletPasswordInfoLabel.text = NSLocalizedString("Please set a password", comment: "")
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                self.walletPasswordInfoLabel.alpha = 1.0
            }, completion: { (_) in
                
            })
            return
        }
        
        if password != GenerateWalletDataManager.shared.password {
            validPassword = false
            self.walletPasswordInfoLabel.text = NSLocalizedString("Please input the consistant password.", comment: "")
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                self.walletPasswordInfoLabel.alpha = 1.0
            }, completion: { (_) in
                
            })
            return
        }

        if validPassword {
            let viewController = GenerateMnemonicViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        
        // Hide the keyboard and adjust the position
        walletPasswordTextField.resignFirstResponder()
        
        self.titleLabel.isHidden = false
        
        if isKeyboardShown {
            UIView.animate(withDuration: 0.4, animations: {
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
                
                if self.walletPasswordTextField.frame.minY - self.keyboardOffsetY < self.titleLabel.frame.minY {
                    self.titleLabel.isHidden = true
                }
                
                if keyboardOffsetY > 0 {
                    UIView.animate(withDuration: 1.0, animations: {
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
