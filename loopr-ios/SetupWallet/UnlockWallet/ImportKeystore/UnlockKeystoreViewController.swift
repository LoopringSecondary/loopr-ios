//
//  KeystoreViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SVProgressHUD

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

        unlockButton.setTitle(LocalizedString("Unlock", comment: ""), for: .normal)
        unlockButton.setupSecondary()
        
        keystoreContentTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        keystoreContentTextView.cornerRadius = 12
        keystoreContentTextView.font = FontConfigManager.shared.getRegularFont()
        keystoreContentTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        keystoreContentTextView.delegate = self
        keystoreContentTextView.text = LocalizedString("Please enter the keystore", comment: "")
        keystoreContentTextView.textColor = .lightGray
        keystoreContentTextView.tintColor = UIColor.black
        
        passwordTextField.delegate = self
        passwordTextField.tag = 0
        passwordTextField.theme_tintColor = GlobalPicker.textColor
        passwordTextField.font = FontConfigManager.shared.getLabelFont(size: 17)
        passwordTextField.placeholder = LocalizedString("Keystore Password", comment: "")
        passwordTextField.contentMode = UIViewContentMode.bottom
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        
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
        if keystoreContentTextView.text == LocalizedString("Please enter the keystore", comment: "") {
            keystoreContentTextView.text = ""
            keystoreContentTextView.textColor = .black
        }
        keystoreContentTextView.becomeFirstResponder() // Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if keystoreContentTextView.text == "" {
            keystoreContentTextView.text = LocalizedString("Please enter the keystore", comment: "")
            keystoreContentTextView.textColor = .lightGray
        }
        keystoreContentTextView.resignFirstResponder()
    }
    
    @IBAction func pressedUnlockButton(_ sender: Any) {
        print("pressedUnlockButton")
        // TODO: Use notificatino to require
        let password = passwordTextField.text ?? ""
        guard password != "" else {
            let notificationTitle = LocalizedString("Please enter a password", comment: "")
            let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
            banner.duration = 1.5
            banner.show()
            return
        }
        
        let keystoreString = self.keystoreContentTextView.text ?? ""
        
        var isSucceeded: Bool = false
        SVProgressHUD.show(withStatus: LocalizedString("Importing keystore", comment: "") + "...")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global().async {
            do {
                try ImportWalletUsingKeystoreDataManager.shared.unlockWallet(keystoreStringValue: keystoreString, password: password)
                isSucceeded = true
                dispatchGroup.leave()
            } catch {
                isSucceeded = false
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            SVProgressHUD.dismiss()
            if isSucceeded {
                if AppWalletDataManager.shared.isDuplicatedAddress(address: ImportWalletUsingKeystoreDataManager.shared.address) {
                    let alert = UIAlertController(title: LocalizedString("Failed to import address. The device has imported the address already.", comment: ""), message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let viewController = ImportWalletEnterWalletNameViewController(setupWalletMethod: .importUsingKeystore)
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let banner = NotificationBanner.generate(title: "Wrong password", style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
    }

}
