//
//  PrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class PrivateKeyViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var privateKeyTextView: UITextView!
    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: UIButton!
    
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(NSLocalizedString("Unlock", comment: ""), for: .normal)
        unlockButton.setupRoundBlack()

        privateKeyTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        privateKeyTextView.cornerRadius = 12
        privateKeyTextView.font = FontConfigManager.shared.getRegularFont()
        privateKeyTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        privateKeyTextView.delegate = self
        privateKeyTextView.text = NSLocalizedString("Please input your private key", comment: "")
        privateKeyTextView.textColor = .lightGray
        privateKeyTextView.tintColor = UIColor.black
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
        if privateKeyTextView.text == NSLocalizedString("Please input your private key", comment: "") {
            privateKeyTextView.text = ""
            privateKeyTextView.textColor = .black
        }
        privateKeyTextView.becomeFirstResponder() //Optional
        // privateKeyTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if privateKeyTextView.text == "" {
            privateKeyTextView.text = NSLocalizedString("Please input your private key", comment: "")
            privateKeyTextView.textColor = .lightGray
        }
        privateKeyTextView.resignFirstResponder()
    }

    @IBAction func pressedUnlockButton(_ sender: Any) {
        print("pressedUnlockButton")
        do {
            try ImportWalletUsingPrivateKeyDataManager.shared.unlockWallet(privateKey: privateKeyTextView.text)
            let viewController = GenerateWalletViewController(setupWalletMethod: .importUsingPrivateKey)
            self.navigationController?.pushViewController(viewController, animated: true)
        } catch {
            let banner = NotificationBanner.generate(title: "Invalid private key. Please enter again.", style: .danger)
            banner.duration = 1.5
            banner.show()
        }
    }

}
