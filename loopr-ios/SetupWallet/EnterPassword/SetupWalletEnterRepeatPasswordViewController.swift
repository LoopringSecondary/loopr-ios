//
//  GenerateWalletEnterRepeatPasswordViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SetupWalletEnterRepeatPasswordViewController: UIViewController, UITextFieldDelegate {

    var setupWalletMethod: QRCodeMethod = .create

    var repeatPasswordTextField: UITextField = UITextField(frame: .zero)
    var continueButton = GradientButton(frame: .zero)
    var errorInfoLabel: UILabel = UILabel(frame: .zero)

    convenience init(setupWalletMethod: QRCodeMethod) {
        let validOptions: [QRCodeMethod] = [.create, .importUsingMnemonic, .importUsingPrivateKey]
        guard validOptions.contains(setupWalletMethod) else {
            preconditionFailure("Invalid setupWalletMethod")
        }

        self.init(nibName: nil, bundle: nil)
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
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Repeat Password", comment: "")
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
        repeatPasswordTextField.placeholder = LocalizedString("Repeat Password", comment: "")
        repeatPasswordTextField.setValue(UIColor.init(white: 1, alpha: 0.4), forKeyPath: "_placeholderLabel.textColor")
        repeatPasswordTextField.contentMode = UIViewContentMode.bottom
        view.addSubview(repeatPasswordTextField)
        
        continueButton = GradientButton(frame: CGRect(x: 48, y: 200, width: screenWidth-48*2, height: 44))
        continueButton.setTitle(LocalizedString("Next", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
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
    
    @objc func pressedContinueButton(_ sender: Any) {
        let password = repeatPasswordTextField.text ?? ""
        
        switch setupWalletMethod {
        case .create:
            if password != GenerateWalletDataManager.shared.password {
                showErrorInfoLabel()
            } else {
                GenerateWalletDataManager.shared.setPassword(repeatPasswordTextField.text!)
                let viewController = BackupMnemonicViewController()
                // Generate a new wallet every time.
                _ = GenerateWalletDataManager.shared.newMnemonics()
                viewController.mnemonics = GenerateWalletDataManager.shared.getMnemonics()
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        case .importUsingMnemonic:
            // If this part of code is executed, it means using mnemonic without password.
            if password != ImportWalletUsingMnemonicDataManager.shared.devicePassword {
                showErrorInfoLabel()
            } else {
                ImportWalletUsingMnemonicDataManager.shared.complete(completion: {(_, error) in
                    if error == nil {
                        self.succeedAndExit(setupWalletMethod: self.setupWalletMethod)
                    } else if error == .duplicatedAddress {
                        self.alertForDuplicatedAddress()
                    } else {
                        self.alertForError()
                    }
                })
            }
        case .importUsingPrivateKey:
            if password != ImportWalletUsingPrivateKeyDataManager.shared.devicePassword {
                showErrorInfoLabel()
            } else {
                ImportWalletUsingPrivateKeyDataManager.shared.complete { (_, error) in
                    if error == nil {
                        self.succeedAndExit(setupWalletMethod: self.setupWalletMethod)
                    } else if error == .duplicatedAddress {
                        self.alertForDuplicatedAddress()
                    } else {
                        self.alertForError()
                    }
                }
            }
        default:
            return
        }
    }
    
    func showErrorInfoLabel() {
        errorInfoLabel.shake()
        errorInfoLabel.alpha = 1.0
        errorInfoLabel.text = LocalizedString("Password doesn't match", comment: "")
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

}
