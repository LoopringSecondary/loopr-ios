//
//  GenerateWalletViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateWalletViewController: UIViewController, UITextFieldDelegate {

    var titleLabel: UILabel =  UILabel()

    // Scrollable UI components
    var walletNameTextField: UITextField = UITextField()
    var walletNameUnderLine: UIView = UIView()
    
    var walletPasswordTextField: UITextField = UITextField()
    var walletPasswordUnderLine: UIView = UIView()
    
    var continueButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = NSLocalizedString("Generate Wallet", comment: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15

        titleLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 30)
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        titleLabel.text = NSLocalizedString("Create a new wallet", comment: "")
        view.addSubview(titleLabel)

        walletNameTextField.delegate = self
        walletNameTextField.tag = 0
        // walletNameTextField.inputView = UIView()
        walletNameTextField.tintColor = UIColor.black
        walletNameTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletNameTextField.placeholder = "Give your wallet an awesome name"
        walletNameTextField.contentMode = UIViewContentMode.bottom
        walletNameTextField.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 80, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletNameTextField)

        walletNameUnderLine.frame = CGRect(x: padding, y: walletNameTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletNameUnderLine.backgroundColor = UIColor.black
        view.addSubview(walletNameUnderLine)

        walletPasswordTextField.delegate = self
        walletPasswordTextField.tag = 1
        // walletPasswordTextField.inputView = UIView()
        walletPasswordTextField.tintColor = UIColor.black
        walletPasswordTextField.font = FontConfigManager.shared.getLabelFont(size: 19)
        walletPasswordTextField.placeholder = "Set a password"
        walletPasswordTextField.contentMode = UIViewContentMode.bottom
        walletPasswordTextField.frame = CGRect(x: padding, y: walletNameUnderLine.frame.maxY + 45, width: screenWidth-padding*2, height: 40)
        view.addSubview(walletPasswordTextField)
        
        walletPasswordUnderLine.frame = CGRect(x: padding, y: walletPasswordTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        walletPasswordUnderLine.backgroundColor = UIColor.black
        view.addSubview(walletPasswordUnderLine)
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        continueButton.setBackgroundColor(UIColor.init(white: 0.3, alpha: 1), for: .highlighted)
        continueButton.clipsToBounds = true
        continueButton.frame = CGRect(x: padding, y: walletPasswordUnderLine.frame.maxY + 50, width: screenWidth - padding * 2, height: 47)
        continueButton.backgroundColor = UIColor.black
        continueButton.layer.cornerRadius = 23
        continueButton.addTarget(self, action: #selector(pressedContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)

        view.theme_backgroundColor = GlobalPicker.backgroundColor

        _ = GenerateWalletDataManager.shared.new()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func pressedContinueButton(_ sender: Any) {
        print("pressedContinueButton")
        
        // TODO: Check if walletNameTextField and walletPasswordTextField have valid input.
        
        GenerateWalletDataManager.shared.setWalletName(walletNameTextField.text!)
        
        let viewController = GenerateWalletConfirmPasswordViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    @objc func systemKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardHeight = keyboardFrame.cgRectValue.height

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            let keyboardMinY = self.view.frame.height - keyboardHeight - bottomPadding
            
            let offsetY = (continueButton.frame.maxY + 20.0) - keyboardMinY

            if offsetY > 0 {
                UIView.animate(withDuration: 1.0, animations: {
                    // Wallet Name
                    var walletNameFrame = self.walletNameTextField.frame
                    walletNameFrame.origin.y -= offsetY
                    self.walletNameTextField.frame = walletNameFrame

                    var walletNameUnderlineFrame = self.walletNameUnderLine.frame
                    walletNameUnderlineFrame.origin.y -= offsetY
                    self.walletNameUnderLine.frame = walletNameUnderlineFrame

                    // Wallet Password
                    var walletPasswordFrame = self.walletPasswordTextField.frame
                    walletPasswordFrame.origin.y -= offsetY
                    self.walletPasswordTextField.frame = walletPasswordFrame
                    
                    var walletPasswordUnderLineFrame = self.walletPasswordUnderLine.frame
                    walletPasswordUnderLineFrame.origin.y -= offsetY
                    self.walletPasswordUnderLine.frame = walletPasswordUnderLineFrame
                    
                    // continueButton
                    var continueButtonFrame = self.continueButton.frame
                    continueButtonFrame.origin.y -= offsetY
                    self.continueButton.frame = continueButtonFrame
                })
            }
        } else {

        }
    }
    
    @objc func systemKeyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        // unlockButtonBottonLayoutContraint.constant = 16.0
    }

}
