//
//  PrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SVProgressHUD

class PrivateKeyViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var privateKeyTextView: UITextView!
    
    // TODO: may remove this NSLayoutConstraint due to the latest UI requirement.
    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: GradientButton!
    
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(LocalizedString("Unlock", comment: ""), for: .normal)

        privateKeyTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 15, right: 10)
        privateKeyTextView.cornerRadius = 6
        privateKeyTextView.font = FontConfigManager.shared.getRegularFont()
        privateKeyTextView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        privateKeyTextView.textColor = Themes.isDark() ? UIColor.init(rgba: "#ffffff66") : UIColor.dark3
        privateKeyTextView.theme_tintColor = GlobalPicker.textLightColor
        privateKeyTextView.delegate = self
        privateKeyTextView.text = LocalizedString("Please input your private key", comment: "")
        privateKeyTextView.keyboardAppearance = Themes.isDark() ? .dark : .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // keyboardWillShow is called after viewDidAppear
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        keyboardHeight = keyboardFrame.cgRectValue.height
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom
        unlockButtonBottonLayoutConstraint.constant = keyboardHeight + 16.0 - bottomPadding!
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        // unlockButtonBottonLayoutContraint.constant = 16.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if privateKeyTextView.text == LocalizedString("Please input your private key", comment: "") {
            privateKeyTextView.text = ""
        }
        privateKeyTextView.theme_textColor = GlobalPicker.textColor
        privateKeyTextView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if privateKeyTextView.text == "" {
            privateKeyTextView.text = LocalizedString("Please input your private key", comment: "")
            privateKeyTextView.textColor = Themes.isDark() ? UIColor.init(rgba: "#ffffff66") : UIColor.dark3
        } else {
            privateKeyTextView.theme_textColor = GlobalPicker.textColor
        }
        privateKeyTextView.resignFirstResponder()
    }

    @IBAction func pressedUnlockButton(_ sender: Any) {
        print("pressedUnlockButton")
        guard privateKeyTextView.text.trim() != "" else {
            let banner = NotificationBanner.generate(title: LocalizedString("Please input your private key", comment: ""), style: .danger)
            banner.duration = 1.5
            banner.show()
            return
        }
        
        do {
            try ImportWalletUsingPrivateKeyDataManager.shared.importWallet(privateKey: privateKeyTextView.text)
            
            // Check if it's duplicated.
            if AppWalletDataManager.shared.isDuplicatedAddress(address: ImportWalletUsingPrivateKeyDataManager.shared.address) {
                let alert = UIAlertController(title: LocalizedString("Failed to import address. The device has imported the address already.", comment: ""), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
                    
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Ask users to enter a password.
            let viewController = ImportWalletEnterWalletNameViewController(setupWalletMethod: .importUsingPrivateKey)
            self.navigationController?.pushViewController(viewController, animated: true)

        } catch {
            let banner = NotificationBanner.generate(title: LocalizedString("Invalid private key. Please enter again.", comment: ""), style: .danger)
            banner.duration = 1.5
            banner.show()
        }
    }

}
