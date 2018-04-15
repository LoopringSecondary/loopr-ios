//
//  PrivateKeyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

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
        
        unlockButton.backgroundColor = UIColor.black
        unlockButton.layer.cornerRadius = 23
        unlockButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 17.0)

        privateKeyTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        privateKeyTextView.cornerRadius = 12
        privateKeyTextView.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17.0)
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
        ImportWalletDataManager.shared.unlockWallet(privateKey: privateKeyTextView.text)

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
