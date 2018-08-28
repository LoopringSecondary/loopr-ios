//
//  AddCustomizedTokenViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import NotificationBannerSwift
import SVProgressHUD

class AddCustomizedTokenViewController: UIViewController, UITextFieldDelegate, DefaultNumericKeyboardDelegate, NumericKeyboardProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // Address
    @IBOutlet weak var addressTextField: UITextField!
    
    // Token Symbol
    @IBOutlet weak var symbolTextField: UITextField!
    
    // Token Symbol
    @IBOutlet weak var decimalTextField: UITextField!
    
    // Send button
    @IBOutlet weak var sendButton: UIButton!
    
    // Numeric keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    var activeTextFieldTag = -1
    
    var address: String = ""
    var symbol: String = ""
    var decimals: Int64 = 18
    
    var errorMessage = [
        "same address was registed": LocalizedString("same address was registed", comment: ""),
        "same symbol exist": LocalizedString("same symbol exist", comment: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Add Custom Token", comment: "")
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        contentView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        contentView.cornerRadius = 6
        contentView.applyShadow()
        
        // Address
        addressTextField.delegate = self
        addressTextField.tag = 0
        addressTextField.keyboardType = .alphabet
        addressTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        addressTextField.font = FontConfigManager.shared.getDigitalFont()
        addressTextField.theme_tintColor = GlobalPicker.contrastTextColor
        addressTextField.placeholder = LocalizedString("Token Address", comment: "")
        addressTextField.text = address
        addressTextField.contentMode = UIViewContentMode.bottom
        addressTextField.setLeftPaddingPoints(13)
        addressTextField.setRightPaddingPoints(9)
        addressTextField.cornerRadius = 6
        
        symbolTextField.delegate = self
        symbolTextField.tag = 1
        symbolTextField.keyboardType = .alphabet
        symbolTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        symbolTextField.autocapitalizationType = .allCharacters
        symbolTextField.font = FontConfigManager.shared.getDigitalFont()
        symbolTextField.theme_tintColor = GlobalPicker.contrastTextColor
        symbolTextField.placeholder = LocalizedString("Token Symbol", comment: "")
        symbolTextField.text = symbol
        symbolTextField.contentMode = UIViewContentMode.bottom
        symbolTextField.setLeftPaddingPoints(9)
        symbolTextField.setRightPaddingPoints(32)
        symbolTextField.cornerRadius = 6
        
        decimalTextField.delegate = self
        decimalTextField.tag = 2
        decimalTextField.inputView = UIView()
        decimalTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        decimalTextField.font = FontConfigManager.shared.getDigitalFont()
        decimalTextField.theme_tintColor = GlobalPicker.contrastTextColor
        decimalTextField.placeholder = LocalizedString("Decimals of Precision", comment: "")
        decimalTextField.text = String(decimals)
        decimalTextField.contentMode = UIViewContentMode.bottom
        decimalTextField.setLeftPaddingPoints(9)
        decimalTextField.setRightPaddingPoints(32)
        decimalTextField.cornerRadius = 6
        
        // Add button
        sendButton.title = LocalizedString("Add", comment: "")
        sendButton.setupSecondary(height: 44)
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.delaysContentTouches = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        addressTextField.resignFirstResponder()
        symbolTextField.resignFirstResponder()
        decimalTextField.resignFirstResponder()
    }

    @IBAction func pressedAddButton(_ sender: Any) {
        if validateAddress() && validateSymbol() && validateDecimals() {
            SVProgressHUD.show(withStatus: LocalizedString("Adding...", comment: ""))
            LoopringAPIRequest.addCustomToken(owner: CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address, tokenContractAddress: self.address, symbol: self.symbol, decimals: self.decimals) { (result, error) in
                
                guard error == nil && result != nil else {
                    SVProgressHUD.dismiss()
                    print("error=\(String(describing: error))")
                    let errorCode = (error! as NSError).userInfo["message"] as! String
                    DispatchQueue.main.async {
                        let notificationTitle = self.errorMessage[errorCode] ?? LocalizedString("Failed to add the token.", comment: "")
                        let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                        banner.duration = 1.5
                        banner.show()
                    }
                    return
                }
                
                TokenDataManager.shared.loadTokensFromServer(completionHandler: {
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.updateTokenList([self.symbol], add: true)
                        let notificationTitle = LocalizedString("Added the token successfully.", comment: "")
                        let banner = NotificationBanner.generate(title: notificationTitle, style: .success)
                        banner.duration = 2
                        banner.show()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }
    
    func validateAddress() -> Bool {
        if var toAddress = addressTextField.text {
            toAddress = toAddress.trim()
            if !toAddress.isEmpty {
                if toAddress.isHexAddress() {
                    var error: NSError?
                    if GethNewAddressFromHex(toAddress, &error) != nil {
                        self.address = toAddress
                        return true
                    }
                }
                let notificationTitle = LocalizedString("Please input a correct address", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            } else {
                let notificationTitle = LocalizedString("Please enter the token address", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
        return false
    }
    
    func validateSymbol() -> Bool {
        if var symbol = symbolTextField.text {
            symbol = symbol.trim()
            if !symbol.isEmpty {
                self.symbol = symbol
                return true
            } else {
                let notificationTitle = LocalizedString("Please enter the token symbol", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
        return false
    }

    func validateDecimals() -> Bool {
        if let decimals = decimalTextField.text {
            if !decimals.isEmpty {
                if let intValue = Int64(decimals) {
                    if intValue >= 0 && intValue <= 20 {
                        self.decimals = intValue
                        return true
                    } else {
                        let notificationTitle = LocalizedString("Decimals of precision must be between 0 and 20", comment: "")
                        let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                        banner.duration = 1.5
                        banner.show()
                    }
                } else {
                    let notificationTitle = LocalizedString("Please input a correct value for decimal", comment: "")
                    let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                    banner.duration = 1.5
                    banner.show()
                }
            } else {
                let notificationTitle = LocalizedString("Please input an deciaml", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 2 {
            showNumericKeyboard(textField: decimalTextField)
        } else {
            hideNumericKeyboard()
        }
        return true
    }
    
    func getActiveTextField() -> UITextField? {
        return decimalTextField
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            numericKeyboardView = DefaultNumericKeyboard.init(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.isIntegerOnly = true
            numericKeyboardView.delegate2 = self
            view.addSubview(numericKeyboardView)
            
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            let destinateY = height - DefaultNumericKeyboard.height - bottomPadding
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { _ in
                self.isNumericKeyboardShow = true
            })
        }
        numericKeyboardView.currentText = textField.text ?? ""
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                self.scrollView.setContentOffset(CGPoint.zero, animated: true)
            }, completion: { _ in
                self.isNumericKeyboardShow = false
            })
        }
    }

    func numericKeyboard(_ numericKeyboard: NumericKeyboard, currentTextDidUpdate currentText: String) {
        let activeTextField: UITextField? = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        decimalTextField!.text = currentText
    }

}
