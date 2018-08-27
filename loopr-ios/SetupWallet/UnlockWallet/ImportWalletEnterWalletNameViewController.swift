//
//  ImportWalletEnterWalletNameViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Crashlytics

class ImportWalletEnterWalletNameViewController: UIViewController, UITextFieldDelegate {

    var setupWalletMethod: QRCodeMethod = .create

    var walletNameTextField: UITextField = UITextField()
    var continueButton: UIButton = UIButton()
    var errorInfoLabel: UILabel = UILabel()

    convenience init(setupWalletMethod: QRCodeMethod) {
        self.init(nibName: "ImportWalletEnterWalletNameViewController", bundle: nil)
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
        self.navigationItem.title = LocalizedString("Wallet Name", comment: "")
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
        
        continueButton.frame = CGRect(x: 48, y: 200, width: screenWidth-48*2, height: 49)
        continueButton.setupSecondary()
        continueButton.setTitle(LocalizedString("Next", comment: ""), for: .normal)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
        
        errorInfoLabel.frame = CGRect(x: padding, y: continueButton.bottomY + 40, width: screenWidth-padding*2, height: 40)
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
        walletNameTextField.becomeFirstResponder()
    }

    @objc func pressedContinueButton(_ sender: Any) {
        guard !AppWalletDataManager.shared.isNewWalletNameToken(newWalletname: walletNameTextField.text ?? "") else {
            errorInfoLabel.shake()
            errorInfoLabel.alpha = 1.0
            errorInfoLabel.text = LocalizedString("The name is token, please try another one.", comment: "")
            return
        }
        
        do {
            switch setupWalletMethod {
            case .importUsingMnemonic:
                if !validation() {
                    return
                }
                walletNameTextField.resignFirstResponder()
                ImportWalletUsingMnemonicDataManager.shared.walletName = walletNameTextField.text!
                importUsingMnemonic()
                return
                
            case .importUsingKeystore:
                if !validation() {
                    return
                }
                walletNameTextField.resignFirstResponder()
                ImportWalletUsingKeystoreDataManager.shared.walletName = walletNameTextField.text!
                try ImportWalletUsingKeystoreDataManager.shared.complete()
                
            case .importUsingPrivateKey:
                if !validation() {
                    return
                }
                walletNameTextField.resignFirstResponder()
                ImportWalletUsingPrivateKeyDataManager.shared.walletName = walletNameTextField.text!
                try ImportWalletUsingPrivateKeyDataManager.shared.complete()
            default:
                return
            }
        } catch AddWalletError.duplicatedAddress {
            alertForDuplicatedAddress()
            return
        } catch {
            alertForError()
            return
        }

        // Exit the whole importing process
        succeedAndExit()
    }
    
    func importUsingMnemonic() {
        ImportWalletUsingMnemonicDataManager.shared.complete(completion: {(appWallet, error) in
            if error == nil {
                self.succeedAndExit()
            } else if error == .duplicatedAddress {
                self.alertForDuplicatedAddress()
            } else {
                self.alertForError()
            }
        })
    }

    func validation() -> Bool {
        var validWalletName = true
        let walletName = walletNameTextField.text ?? ""
        if walletName.trim() == "" {
            validWalletName = false
            errorInfoLabel.shake()
            errorInfoLabel.alpha = 1.0
            errorInfoLabel.text = LocalizedString("New wallet name can't be empty", comment: "")
        }
        return validWalletName
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if walletNameTextField.isFirstResponder == true {
            walletNameTextField.placeholder = ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.utf16.count)! + (string.utf16.count) - range.length
        print("textField shouldChangeCharactersIn \(newLength)")
        errorInfoLabel.alpha = 0.0
        errorInfoLabel.text = ""
        return true
    }

    func succeedAndExit() {
        Answers.logSignUp(withMethod: setupWalletMethod.description, success: true, customAttributes: nil)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = MainTabController()
    }
    
}
