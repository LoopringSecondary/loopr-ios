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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemKeyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(NSLocalizedString("Unlock", comment: ""), for: .normal)
        
        unlockButton.backgroundColor = UIColor.black
        unlockButton.layer.cornerRadius = 23
        unlockButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 17.0)        

        // TODO: This setting doesn't work.
        mnemonicWordTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        mnemonicWordTextView.contentOffset = CGPoint(x: 0, y: -10)

        mnemonicWordTextView.cornerRadius = 12
        mnemonicWordTextView.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17.0)
        mnemonicWordTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        mnemonicWordTextView.delegate = self
        mnemonicWordTextView.text = NSLocalizedString("Please use space to seperate the mnemonic words", comment: "")
        mnemonicWordTextView.textColor = .lightGray
        mnemonicWordTextView.tintColor = UIColor.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // keyboardWillShow is called after viewDidAppear
    @objc func systemKeyboardWillShow(_ notification: Notification) {
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
    
    @objc func systemKeyboardWillDisappear(notification: NSNotification?) {
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
        AppWalletDataManager.shared.unlockWallet(mnemonic: mnemonicWordTextView.text)
        
        if SetupDataManager.shared.hasPresented {
            self.dismiss(animated: true, completion: {
                
            })
        } else {
            SetupDataManager.shared.hasPresented = true
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        }
    }

}
