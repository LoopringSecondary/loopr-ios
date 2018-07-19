//
//  MnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class MnemonicViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mnemonicWordTextView: UITextView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldUnderline: UIView!
    
    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: UIButton!
    
    var isKeyboardShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(LocalizedString("Unlock", comment: ""), for: .normal)
        unlockButton.setupSecondary()

        mnemonicWordTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        mnemonicWordTextView.cornerRadius = 12
        mnemonicWordTextView.font = FontConfigManager.shared.getRegularFont()
        mnemonicWordTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        mnemonicWordTextView.delegate = self
        mnemonicWordTextView.text = LocalizedString("Please use space to seperate the mnemonic words", comment: "")
        mnemonicWordTextView.textColor = .lightGray
        mnemonicWordTextView.tintColor = UIColor.black
        
        // passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.font = FontConfigManager.shared.getDigitalFont(size: 17)
        passwordTextField.placeholder = LocalizedString("Mnemonic Password (optional)", comment: "")
        passwordTextField.contentMode = UIViewContentMode.bottom
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        
        passwordTextFieldUnderline.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(scrollViewTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unlockButton.setupSecondary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        // Hide the keyboard and adjust the position
        mnemonicWordTextView.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    // keyboardWillShow is called after viewDidAppear
    @objc func systemKeyboardWillShow(_ notification: Notification) {
        guard isKeyboardShown == false else {
            return
        }

        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        if #available(iOS 11.0, *) {
            // Get the the distance from the bottom safe area edge to the bottom of the screen
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                self.unlockButtonBottonLayoutConstraint.constant = keyboardHeight + 16.0 - bottomPadding!
                // animation for layout constraint change.
                self.view.layoutIfNeeded()

            }, completion: { (_) in
                self.isKeyboardShown = true
            })
        } else {
            unlockButtonBottonLayoutConstraint.constant = keyboardHeight + 16.0
        }
    }
    
    @objc func systemKeyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        // unlockButtonBottonLayoutContraint.constant = 16.0
        self.isKeyboardShown = false
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if mnemonicWordTextView.text == LocalizedString("Please use space to seperate the mnemonic words", comment: "") {
            mnemonicWordTextView.text = ""
            mnemonicWordTextView.textColor = .black
        }
        mnemonicWordTextView.becomeFirstResponder() // Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if mnemonicWordTextView.text == "" {
            mnemonicWordTextView.text = LocalizedString("Please use space to seperate the mnemonic words", comment: "")
            mnemonicWordTextView.textColor = .lightGray
        }
        mnemonicWordTextView.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.utf16.count)! + (string.utf16.count) - range.length
        print("textField shouldChangeCharactersIn \(newLength)")

        switch textField.tag {
        case passwordTextField.tag:
            if newLength > 0 {
                passwordTextFieldUnderline.backgroundColor = UIColor.black
            } else {
                passwordTextFieldUnderline.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        default: ()
        }
        return true
    }
    
    @IBAction func pressUnlockButton(_ sender: Any) {
        print("pressUnlockButton")
        let password = passwordTextField.text ?? ""
        let mnemonic = mnemonicWordTextView.text.trim()

        guard Mnemonic.isValid(mnemonic) else {
            let notificationTitle = LocalizedString("Invalid mnemonic. Please enter again.", comment: "")
            let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
            banner.duration = 1.5
            banner.show()
            return
        }
        
        ImportWalletUsingMnemonicDataManager.shared.mnemonic = mnemonicWordTextView.text.trim()
        ImportWalletUsingMnemonicDataManager.shared.password = password

        let viewController = MnemonicEnterDerivationPathViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
