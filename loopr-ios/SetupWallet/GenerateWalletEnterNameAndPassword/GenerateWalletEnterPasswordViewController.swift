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
        
        passwordTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.theme_textColor = GlobalPicker.textColor
        passwordTextField.textAlignment = .center
        passwordTextField.font = FontConfigManager.shared.getRegularFont(size: 18)
        passwordTextField.placeholder = LocalizedString("Password", comment: "")
        passwordTextField.setValue(UIColor.init(white: 1, alpha: 0.4), forKeyPath: "_placeholderLabel.textColor")
        passwordTextField.contentMode = UIViewContentMode.bottom
        view.addSubview(passwordTextField)
        
        continueButton.frame = CGRect(x: 48, y: 200, width: screenWidth-48*2, height: 49)
        continueButton.setupSecondary()
        continueButton.setTitle(LocalizedString("Next", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func pressedContinueButton(_ sender: Any) {
        let viewController = GenerateWalletEnterRepeatPasswordViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if passwordTextField.isFirstResponder == true {
            passwordTextField.placeholder = ""
        }
    }

}
