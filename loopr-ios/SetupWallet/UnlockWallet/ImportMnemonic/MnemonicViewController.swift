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
    
    // TODO: may remove this NSLayoutConstraint due to the latest UI requirement.
    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: UIButton!
    
    var isKeyboardShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor

        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(LocalizedString("Unlock", comment: ""), for: .normal)
        unlockButton.setupSecondary(height: 44)

        mnemonicWordTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 15, right: 10)
        mnemonicWordTextView.cornerRadius = 6
        mnemonicWordTextView.font = FontConfigManager.shared.getRegularFont()
        mnemonicWordTextView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        mnemonicWordTextView.textColor = Themes.isDark() ? UIColor.init(rgba: "#ffffff66") : UIColor.dark3
        mnemonicWordTextView.theme_tintColor = GlobalPicker.textColor
        mnemonicWordTextView.delegate = self
        mnemonicWordTextView.text = LocalizedString("Please use space to seperate the mnemonic words", comment: "")
        mnemonicWordTextView.keyboardAppearance = Themes.isDark() ? .dark : .default
        
        passwordTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.theme_backgroundColor = ColorPicker.cardBackgroundColor
        passwordTextField.theme_textColor = GlobalPicker.textColor
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.font = FontConfigManager.shared.getRegularFont()
        passwordTextField.placeholder = LocalizedString("Mnemonic Password (optional)", comment: "")
        passwordTextField.placeHolderColor = Themes.isDark() ? UIColor.init(rgba: "#ffffff66") : UIColor.dark3
        passwordTextField.contentMode = UIViewContentMode.bottom
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        passwordTextField.cornerRadius = 6
        passwordTextField.keyboardAppearance = Themes.isDark() ? .dark : .default

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(scrollViewTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unlockButton.setupSecondary(height: 44)
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
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.unlockButtonBottonLayoutConstraint.constant = keyboardHeight + 16.0 - bottomPadding!
            // animation for layout constraint change.
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.isKeyboardShown = true
        })
    }
    
    @objc func systemKeyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        // unlockButtonBottonLayoutContraint.constant = 16.0
        self.isKeyboardShown = false
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if mnemonicWordTextView.text == LocalizedString("Please use space to seperate the mnemonic words", comment: "") {
            mnemonicWordTextView.text = ""
        }
        mnemonicWordTextView.theme_textColor = GlobalPicker.textColor
        mnemonicWordTextView.becomeFirstResponder() // Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if mnemonicWordTextView.text == "" {
            mnemonicWordTextView.text = LocalizedString("Please use space to seperate the mnemonic words", comment: "")
            mnemonicWordTextView.textColor = Themes.isDark() ? UIColor.init(rgba: "#ffffff66") : UIColor.dark3
        } else {
            mnemonicWordTextView.theme_textColor = GlobalPicker.textColor
        }
        mnemonicWordTextView.resignFirstResponder()
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
