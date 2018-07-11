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
    @IBOutlet weak var unlockButtonBottonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlockButton: UIButton!
    
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

        unlockButton.setTitle(LocalizedString("Unlock", comment: ""), for: .normal)
        unlockButton.setupRoundBlack()

        privateKeyTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        privateKeyTextView.cornerRadius = 12
        privateKeyTextView.font = FontConfigManager.shared.getRegularFont()
        privateKeyTextView.backgroundColor = UIColor.init(rgba: "#F8F8F8")
        privateKeyTextView.delegate = self
        privateKeyTextView.text = LocalizedString("Please input your private key", comment: "")
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
        if privateKeyTextView.text == LocalizedString("Please input your private key", comment: "") {
            privateKeyTextView.text = ""
            privateKeyTextView.textColor = .black
        }
        privateKeyTextView.becomeFirstResponder() //Optional
        // privateKeyTextView.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if privateKeyTextView.text == "" {
            privateKeyTextView.text = LocalizedString("Please input your private key", comment: "")
            privateKeyTextView.textColor = .lightGray
        }
        privateKeyTextView.resignFirstResponder()
    }

    @IBAction func pressedUnlockButton(_ sender: Any) {
        print("pressedUnlockButton")
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
            
            // Generate a keystore
            generateTempKeystore()

        } catch {
            let banner = NotificationBanner.generate(title: LocalizedString("Invalid private key. Please enter again.", comment: ""), style: .danger)
            banner.duration = 1.5
            banner.show()
        }
    }
    
    func generateTempKeystore() {
        var isSucceeded: Bool = false
        SVProgressHUD.show(withStatus: LocalizedString("Initializing the wallet", comment: "") + "...")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global().async {
            do {
                guard let data = Data(hexString: ImportWalletUsingPrivateKeyDataManager.shared.getPrivateKey()) else {
                    print("Invalid private key")
                    return // .failure(KeystoreError.failedToImportPrivateKey)
                }
                
                print("Generating keystore")
                let key = try KeystoreKey(password: "123456", key: data)
                print("Finished generating keystore")
                let keystoreData = try JSONEncoder().encode(key)
                let json = try JSON(data: keystoreData)

                ImportWalletUsingPrivateKeyDataManager.shared.setKeystore(keystore: json.description)
                
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
                let viewController = ImportWalletEnterWalletNameViewController(setupWalletMethod: .importUsingPrivateKey)
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let banner = NotificationBanner.generate(title: "Wrong password", style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
    }

}
