//
//  KeystoreViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class UnlockKeystoreViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var keystoreContentTextView: UITextView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldUnderline: UIView!

    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(NSLocalizedString("Unlock", comment: ""), for: .normal)
        
        unlockButton.backgroundColor = UIColor.black
        unlockButton.layer.cornerRadius = 23
        unlockButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 17.0)
        
        keystoreContentTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        keystoreContentTextView.cornerRadius = 12
        keystoreContentTextView.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17.0)
        keystoreContentTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        keystoreContentTextView.delegate = self
        keystoreContentTextView.text = NSLocalizedString("Please use space to seperate the mnemonic words", comment: "")
        keystoreContentTextView.textColor = .lightGray
        keystoreContentTextView.tintColor = UIColor.black
        
        passwordTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.font = FontConfigManager.shared.getLabelFont(size: 17)
        passwordTextField.placeholder = "Keystore Password"
        passwordTextField.contentMode = UIViewContentMode.bottom
        
        passwordTextFieldUnderline.backgroundColor = UIColor.black.withAlphaComponent(0.1)

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(scrollViewTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        // Hide the keyboard and adjust the position
        keystoreContentTextView.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // keyboardWillShow is called after viewDidAppear
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        if #available(iOS 11.0, *) {
            // Get the the distance from the bottom safe area edge to the bottom of the screen
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            unlockButtonBottonLayoutConstraint.constant = keyboardHeight + 16.0 - bottomPadding!
        } else {
            unlockButtonBottonLayoutConstraint.constant = keyboardHeight + 16.0
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        // unlockButtonBottonLayoutContraint.constant = 16.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if keystoreContentTextView.text == NSLocalizedString("Please use space to seperate the mnemonic words", comment: "") {
            keystoreContentTextView.text = ""
            keystoreContentTextView.textColor = .black
        }
        keystoreContentTextView.becomeFirstResponder() // Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if keystoreContentTextView.text == "" {
            keystoreContentTextView.text = NSLocalizedString("Please use space to seperate the mnemonic words", comment: "")
            keystoreContentTextView.textColor = .lightGray
        }
        keystoreContentTextView.resignFirstResponder()
    }
    
    @IBAction func pressedUnlockButton(_ sender: Any) {
        print("pressedUnlockButton")

        ImportWalletUsingKeystoreDataManager.shared.unlockWallet(keystoreStringValue: keystoreContentTextView.text, password: passwordTextField.text ?? "")
        
        let viewController = GenerateWalletViewController(setupWalletMethod: .unlock)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
