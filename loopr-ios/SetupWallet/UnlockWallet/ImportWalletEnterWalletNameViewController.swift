//
//  ImportWalletEnterWalletNameViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class ImportWalletEnterWalletNameViewController: UIViewController, UITextFieldDelegate {

    var setupWalletMethod: SetupWalletMethod = .create

    var walletNameTextField: UITextField = UITextField()
    var walletNameUnderLine: UIView = UIView()
    var walletNameInfoLabel: UILabel = UILabel()

    var continueButton: UIButton = UIButton()

    convenience init(setupWalletMethod: SetupWalletMethod) {
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
        setBackButton()

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

        continueButton.setTitle(NSLocalizedString("Enter Wallet", comment: ""), for: .normal)
        continueButton.setupRoundBlack()
        continueButton.frame = CGRect(x: padding, y: walletNameInfoLabel.frame.maxY + 50, width: screenWidth - padding * 2, height: 47)
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pressedContinueButton(_ sender: Any) {
        guard AppWalletDataManager.shared.isNewWalletNameToken(newWalletname: walletNameTextField.text ?? "") else {
            let title = NSLocalizedString("The name is token, please try another one", comment: "")
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        do {
            switch setupWalletMethod {
            case .importUsingMnemonic:
                if !validation() {
                    return
                }
                walletNameTextField.resignFirstResponder()
                ImportWalletUsingMnemonicDataManager.shared.walletName = walletNameTextField.text ?? ""
                try ImportWalletUsingMnemonicDataManager.shared.complete()
                
            case .importUsingKeystore:
                if !validation() {
                    return
                }
                walletNameTextField.resignFirstResponder()
                ImportWalletUsingKeystoreDataManager.shared.walletName = walletNameTextField.text ?? ""
                try ImportWalletUsingKeystoreDataManager.shared.complete()
                
            case .importUsingPrivateKey:
                if !validation() {
                    return
                }
                walletNameTextField.resignFirstResponder()
                ImportWalletUsingPrivateKeyDataManager.shared.walletName = walletNameTextField.text ?? ""
                try ImportWalletUsingPrivateKeyDataManager.shared.complete()
            default:
                return
            }
        } catch AddWalletError.duplicatedAddress {
            
        } catch {
            
        }

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

    func validation() -> Bool {
        var validWalletName = true
        let walletName = walletNameTextField.text ?? ""
        if walletName.trim() == "" {
            validWalletName = false
            self.walletNameInfoLabel.shake()
            self.walletNameInfoLabel.alpha = 1.0
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
        default: ()
        }
        return true
    }

}
