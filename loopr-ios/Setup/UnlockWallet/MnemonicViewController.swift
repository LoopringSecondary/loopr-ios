//
//  MnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var mnemonicWordTextView: UITextView!
    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: UIButton!
    
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        unlockButton.setTitle(NSLocalizedString("Unlock", comment: ""), for: .normal)
        
        mnemonicWordTextView.delegate = self
        mnemonicWordTextView.text = NSLocalizedString("Please use space to seperate the mnemonic words", comment: "")
        mnemonicWordTextView.textColor = .lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // mnemonicWordTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if mnemonicWordTextView.text == NSLocalizedString("Please use space to seperate the mnemonic words", comment: "") {
            mnemonicWordTextView.text = ""
            mnemonicWordTextView.textColor = .black
        }
        mnemonicWordTextView.becomeFirstResponder() // Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if mnemonicWordTextView.text == "" {
            mnemonicWordTextView.text = NSLocalizedString("Please use space to seperate the mnemonic words", comment: "")
            mnemonicWordTextView.textColor = .lightGray
        }
        mnemonicWordTextView.resignFirstResponder()
    }
    
    @IBAction func pressUnlockButton(_ sender: Any) {
        print("pressUnlockButton")
        WalletDataManager.shared.unlockWallet(mnemonic: mnemonicWordTextView.text)
        self.dismiss(animated: true) {
            
        }
    }

}
