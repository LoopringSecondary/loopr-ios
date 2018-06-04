//
//  ExportKeystoreEnterPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class ExportKeystoreEnterPasswordViewController: UIViewController, UITextFieldDelegate {

    var appWallet: AppWallet!

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
        
        var validPassword = true
        let password = passwordTextField.text ?? ""
        if password.trim() == "" {
            validPassword = false
            self.passwordInfoLabel.text = NSLocalizedString("Empty password", comment: "")
        }
        
        if appWallet.setupWalletMethod != .importUsingPrivateKey && password.trim() != appWallet.getPassword() {
            validPassword = false
            self.passwordInfoLabel.text = NSLocalizedString("Wrong password", comment: "")
        }

        if validPassword {
            let viewController = ExportKeystoreSwipeViewController()
            viewController.appWallet = appWallet
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            self.passwordInfoLabel.alpha = 1.0
            self.passwordInfoLabel.shake()
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
