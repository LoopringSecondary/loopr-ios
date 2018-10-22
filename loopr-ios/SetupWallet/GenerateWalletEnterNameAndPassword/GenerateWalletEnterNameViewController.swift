//
//  GenerateWalletEnterNameViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletEnterNameViewController: UIViewController, UITextFieldDelegate {
    
    var walletNameTextField: UITextField = UITextField(frame: .zero)
    var continueButton: GradientButton = GradientButton(frame: .zero)
    var errorInfoLabel: UILabel = UILabel(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Enter Wallet Name", comment: "")
        setBackButton()

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width

        let originY: CGFloat = 80
        let padding: CGFloat = 15

        walletNameTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2, height: 40)
        
        walletNameTextField.delegate = self
        walletNameTextField.tag = 0
        walletNameTextField.theme_tintColor = GlobalPicker.textColor
        walletNameTextField.theme_textColor = GlobalPicker.textColor
        walletNameTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        walletNameTextField.textAlignment = .center
        walletNameTextField.font = FontConfigManager.shared.getRegularFont(size: 18)
        walletNameTextField.placeholder = LocalizedString("Wallet Name", comment: "")
        walletNameTextField.setValue(UIColor.init(white: 1, alpha: 0.4), forKeyPath: "_placeholderLabel.textColor")
        walletNameTextField.contentMode = UIViewContentMode.bottom
        view.addSubview(walletNameTextField)
        
        continueButton = GradientButton(frame: CGRect(x: 48, y: 200, width: screenWidth-48*2, height: 44))
        continueButton.setTitle(LocalizedString("Next", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
        
        errorInfoLabel.frame = CGRect(x: padding, y: continueButton.bottomY + 40, width: screenWidth-padding*2, height: 17)
        errorInfoLabel.textColor = UIColor.fail
        errorInfoLabel.textAlignment = .center
        errorInfoLabel.alpha = 0.0
        errorInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        view.addSubview(errorInfoLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        walletNameTextField.becomeFirstResponder()
    }

    @objc func pressedContinueButton(_ sender: Any) {
        var validWalletName = true
        
        let walletName = walletNameTextField.text ?? ""
        if walletName.trim() == "" {
            validWalletName = false
            errorInfoLabel.shake()
            errorInfoLabel.alpha = 1.0
            errorInfoLabel.text = LocalizedString("New wallet name can't be empty", comment: "")
        }
        
        if AppWalletDataManager.shared.isNewWalletNameToken(newWalletname: walletName.trim()) {
            validWalletName = false
            errorInfoLabel.shake()
            errorInfoLabel.alpha = 1.0
            errorInfoLabel.text = LocalizedString("The name is taken, please try another one.", comment: "")
        }
        
        if validWalletName {
            GenerateWalletDataManager.shared.setWalletName(walletNameTextField.text!)
            let viewController = GenerateWalletEnterPasswordViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if walletNameTextField.isFirstResponder == true {
            walletNameTextField.placeholder = ""
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorInfoLabel.alpha = 0.0
        errorInfoLabel.text = ""
        return true
    }

}
