//
//  GenerateWalletEnterPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletEnterPasswordViewController: UIViewController, UITextFieldDelegate {

    var passwordTextField: UITextField = UITextField()
    var continueButton: UIButton = UIButton()
    var errorInfoLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Generate Wallet", comment: "")
        setBackButton()
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        let originY: CGFloat = 80
        let padding: CGFloat = 15
        
        passwordTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 40)
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.theme_textColor = GlobalPicker.textColor
        passwordTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        passwordTextField.textAlignment = .center
        passwordTextField.font = FontConfigManager.shared.getRegularFont(size: 18)
        passwordTextField.placeholder = LocalizedString("Password", comment: "")
        passwordTextField.setValue(UIColor.init(white: 1, alpha: 0.4), forKeyPath: "_placeholderLabel.textColor")
        passwordTextField.contentMode = UIViewContentMode.bottom
        view.addSubview(passwordTextField)
        
        continueButton.frame = CGRect(x: 48, y: 200, width: screenWidth-48*2, height: 44)
        continueButton.setupSecondary(height: 44)
        continueButton.setTitle(LocalizedString("Next", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)

        errorInfoLabel.frame = CGRect(x: 48, y: continueButton.bottomY + 40, width: screenWidth-48*2, height: 50)
        errorInfoLabel.textAlignment = .center
        errorInfoLabel.numberOfLines = 2
        errorInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        view.addSubview(errorInfoLabel)

        errorInfoLabel.theme_textColor = GlobalPicker.textLightColor
        errorInfoLabel.alpha = 1.0
        errorInfoLabel.text = LocalizedString("The length of password needs to be larger than or equal to 6.", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    @objc func pressedContinueButton(_ sender: Any) {
        var validPassword = true
        
        let password = passwordTextField.text ?? ""
        if password.trim().count == 0 {
            validPassword = false
            errorInfoLabel.shake()
            errorInfoLabel.textColor = UIColor.themeRed
            errorInfoLabel.alpha = 1.0
            errorInfoLabel.text = LocalizedString("Password can't be empty.", comment: "")
        }

        if password.count < 6 {
            validPassword = false
            errorInfoLabel.shake()
            errorInfoLabel.textColor = UIColor.themeRed
            errorInfoLabel.alpha = 1.0
            errorInfoLabel.text = LocalizedString("The length of password needs to be larger than or equal to 6.", comment: "")
        }

        if validPassword {
            GenerateWalletDataManager.shared.setPassword(passwordTextField.text!)
            let viewController = GenerateWalletEnterRepeatPasswordViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if passwordTextField.isFirstResponder == true {
            passwordTextField.placeholder = ""
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.utf16.count)! + (string.utf16.count) - range.length
        print("textField shouldChangeCharactersIn \(newLength)")
        errorInfoLabel.theme_textColor = GlobalPicker.textLightColor
        errorInfoLabel.alpha = 1.0
        errorInfoLabel.text = LocalizedString("The length of password needs to be larger than or equal to 6.", comment: "")
        return true
    }

}
