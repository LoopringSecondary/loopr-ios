//
//  SendAssetViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import NotificationBannerSwift
import SVProgressHUD

class SendAssetViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, DefaultNumericKeyboardDelegate, NumericKeyboardProtocol, QRCodeScanProtocol, AmountStackViewDelegate {

    var asset: Asset!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBackgroundView: UIView!
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var sendButtonBackgroundViewBottomLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBackgroundViewHeightLayoutContraint: NSLayoutConstraint!
    
    // Token
    var tokenIconImageView = UIImageView()
    var tokenTotalAmountLabel = UILabel()

    // Address
    var addressY: CGFloat = 0.0
    var addressTextField: UITextField = UITextField()
    var scanButton: UIButton = UIButton()
    var addressUnderLine: UIView = UIView()
    var addressInfoLabel: UILabel = UILabel()

    // Amount
    var amountY: CGFloat = 0.0
    var amountTextField: UITextField = UITextField()
    var tokenSymbolLabel: UILabel = UILabel()
    var amountUnderline: UIView = UIView()
    var amountTradeImage: UIImageView = UIImageView()
    var amountInfoLabel: UILabel = UILabel()
    var amountStackView: AmountStackView!
    
    // Transaction Fee
    var transactionFeeLabel = UILabel()
    var transactionFeeAmountLabel = UILabel()
    
    // Advanced
    /*
    var advancedButton: UIButton = UIButton()
    var showAdvanced: Bool = false
    */
    var transactionSpeedSlider = UISlider()
    var transactionAmountMinLabel = UILabel()
    var transactionAmountMaxLabel = UILabel()
    var transactionAmountCurrentLabel = UILabel()
    var transactionAmountHelpButton = UIButton()
    
    // Numeric keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    var activeTextFieldTag = -1
    
    // To measure the performance. Will be removed in the future
    var start = Date()
    var end = Date()
    
    // TODO: should set the default value using the gwei value in GasDataManager
    // Reference: https://ethgasstation.info
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setBackButton()

        sendButton.setTitleColor(.gray, for: .disabled)
        sendButton.title = LocalizedString("Send", comment: "")
        sendButton.setupRoundBlack()
        scrollViewButtonLayoutConstraint.constant = 47*UIStyleConfig.scale + 15*2

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            sendButtonBackgroundViewBottomLayoutContraint.constant = bottomPadding
        } else {
            sendButtonBackgroundViewBottomLayoutContraint.constant = 0
        }

        sendButtonBackgroundViewHeightLayoutContraint.constant = 47*UIStyleConfig.scale + 15*2

        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 50
        let padding: CGFloat = 15
        
        // First row: token
        tokenIconImageView.frame = CGRect(center: CGPoint(x: screenWidth*0.5, y: originY), size: CGSize(width: 54, height: 54))
        tokenIconImageView.image = UIImage(named: "ETH")
        scrollView.addSubview(tokenIconImageView)
        
        tokenTotalAmountLabel.frame = CGRect(center: CGPoint(x: screenWidth*0.5, y: tokenIconImageView.frame.maxY + 30), size: CGSize(width: screenWidth - 2*padding, height: 21))
        tokenTotalAmountLabel.textAlignment = .center
        tokenTotalAmountLabel.font = FontConfigManager.shared.getLabelFont()
        scrollView.addSubview(tokenTotalAmountLabel)
        
        // Second row: address

        addressTextField.delegate = self
        addressTextField.tag = 0
        addressTextField.keyboardType = .alphabet
        addressTextField.font = FontConfigManager.shared.getLabelFont()
        addressTextField.theme_tintColor = GlobalPicker.textColor
        addressTextField.placeholder = LocalizedString("Enter the address", comment: "")
        addressTextField.contentMode = UIViewContentMode.bottom
        addressTextField.frame = CGRect(x: padding, y: tokenTotalAmountLabel.frame.maxY + padding*3, width: screenWidth-padding*2-40, height: 40)
        scrollView.addSubview(addressTextField)
        addressY = addressTextField.frame.minY
        
        scanButton.image = UIImage(named: "Scan")
        scanButton.frame = CGRect(x: screenWidth-padding-30, y: addressTextField.frame.origin.y, width: 40, height: 40)
        scanButton.addTarget(self, action: #selector(pressedScanButton(_:)), for: .touchUpInside)
        scrollView.addSubview(scanButton)
        
        addressUnderLine.frame = CGRect(x: padding, y: addressTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        addressUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(addressUnderLine)

        addressInfoLabel.frame = CGRect(x: padding, y: addressUnderLine.frame.maxY, width: screenWidth - padding * 2, height: 40)
        addressInfoLabel.font = FontConfigManager.shared.getLabelFont()
        addressInfoLabel.text = LocalizedString("Please confirm the address before sending", comment: "")
        scrollView.addSubview(addressInfoLabel)
        
        // Third row: Amount
        
        amountTextField.delegate = self
        amountTextField.inputView = UIView()
        amountTextField.tag = 1
        amountTextField.font = FontConfigManager.shared.getLabelFont()
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.placeholder = LocalizedString("Enter the amount", comment: "")
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: addressInfoLabel.frame.maxY + padding*1.5, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountTextField)
        amountY = amountTextField.frame.minY

        tokenSymbolLabel.font = FontConfigManager.shared.getLabelFont()
        tokenSymbolLabel.textAlignment = .right
        tokenSymbolLabel.frame = CGRect(x: screenWidth-padding-80, y: amountTextField.frame.origin.y, width: 80, height: 40)
        scrollView.addSubview(tokenSymbolLabel)
        
        amountUnderline.frame = CGRect(x: padding, y: amountTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderline.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderline)
        
        amountTradeImage.image = UIImage(named: "Transaction_convert_income")
        amountTradeImage.frame = CGRect(x: padding, y: amountUnderline.frame.maxY + 13, width: 15, height: 15)
        scrollView.addSubview(amountTradeImage)
        
        amountInfoLabel.frame = CGRect(x: padding*2 + 10, y: amountUnderline.frame.maxY, width: screenWidth - padding * 2, height: 40)
        amountInfoLabel.font = FontConfigManager.shared.getLabelFont()
        amountInfoLabel.text = 0.0.currency
        scrollView.addSubview(amountInfoLabel)
        
        amountStackView = AmountStackView(frame: CGRect(x: screenWidth-100-padding, y: amountUnderline.frame.maxY, width: 100, height: 40))
        amountStackView.delegate = self
        scrollView.addSubview(amountStackView)
        
        transactionFeeLabel.frame = CGRect(x: padding, y: amountInfoLabel.frame.maxY + padding*2, width: 160, height: 40)
        transactionFeeLabel.font = FontConfigManager.shared.getLabelFont()
        transactionFeeLabel.text = LocalizedString("Transaction Fee", comment: "")
        scrollView.addSubview(transactionFeeLabel)
        
        transactionFeeAmountLabel.frame = CGRect(x: screenWidth-300-padding, y: amountInfoLabel.frame.maxY + padding*2, width: 300, height: 40)
        transactionFeeAmountLabel.font = FontConfigManager.shared.getLabelFont()
        transactionFeeAmountLabel.textAlignment = .right
        transactionFeeAmountLabel.text = ""
        scrollView.addSubview(transactionFeeAmountLabel)
        updateTransactionFeeAmountLabel()

        // Fouth row: Advanced
        /*
        advancedButton.frame = CGRect(x: padding, y: transactionFeeAmountLabel.frame.maxY + padding, width: 100, height: 40)
        advancedButton.setTitleColor(UIColor.black, for: .normal)
        advancedButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        advancedButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        advancedButton.title = LocalizedString("Advanced", comment: "")
        advancedButton.setRightImage(imageName: "Arrow-button-right-light", imagePaddingTop: 0, imagePaddingLeft: 10, titlePaddingRight: 11)
        advancedButton.addTarget(self, action: #selector(pressedAdvancedButton(_:)), for: .touchUpInside)
        scrollView.addSubview(advancedButton)
        */

        transactionSpeedSlider.frame = CGRect(x: padding, y: transactionFeeAmountLabel.frame.maxY + padding, width: screenWidth-2*padding, height: 20)
        
        // TODO: Set value
        /*
         // DefaultSlider setting
        transactionSpeedSlider.minValue = 1
        transactionSpeedSlider.maxValue = CGFloat(Float(gasPriceInGwei * 2))
        transactionSpeedSlider.colorBetweenHandles = UIColor.red
        transactionSpeedSlider.lineHeight = 2
        */
        
        transactionSpeedSlider.minimumValue = 1
        transactionSpeedSlider.maximumValue = Float(gasPriceInGwei * 2) <= 20 ? 20 : Float(gasPriceInGwei * 2)
        transactionSpeedSlider.value = Float(gasPriceInGwei)
        
        //transactionSpeedSlider.isContinuous = true
        transactionSpeedSlider.tintColor = UIColor.black
        transactionSpeedSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        scrollView.addSubview(transactionSpeedSlider)

        transactionAmountMinLabel.frame = CGRect(x: padding, y: transactionSpeedSlider.frame.maxY + 10, width: (screenWidth-2*padding)/8, height: 30)
        transactionAmountMinLabel.font = FontConfigManager.shared.getLabelFont()
        transactionAmountMinLabel.text = LocalizedString("Slow", comment: "")
        scrollView.addSubview(transactionAmountMinLabel)
        
        transactionAmountCurrentLabel.textAlignment = .center
        transactionAmountCurrentLabel.frame = CGRect(x: transactionAmountMinLabel.frame.maxX, y: transactionAmountMinLabel.frame.minY, width: (screenWidth-2*padding)*3/4, height: 30)
        transactionAmountCurrentLabel.font = FontConfigManager.shared.getLabelFont()
        transactionAmountCurrentLabel.text = LocalizedString("gas price", comment: "") + ": \(gasPriceInGwei) gwei"
        
        scrollView.addSubview(transactionAmountCurrentLabel)
        
        let pad = (transactionAmountCurrentLabel.frame.width - transactionAmountCurrentLabel.intrinsicContentSize.width) / 2
        transactionAmountHelpButton.frame = CGRect(x: transactionAmountCurrentLabel.frame.maxX - pad, y: transactionAmountCurrentLabel.frame.minY, width: 30, height: 30)
        transactionAmountHelpButton.image = UIImage(named: "HelpIcon")
        transactionAmountHelpButton.addTarget(self, action: #selector(pressedHelpButton), for: .touchUpInside)
        scrollView.addSubview(transactionAmountHelpButton)
        
        transactionAmountMaxLabel.textAlignment = .right
        transactionAmountMaxLabel.frame = CGRect(x: transactionAmountCurrentLabel.frame.maxX, y: transactionAmountMinLabel.frame.minY, width: (screenWidth-2*padding)/8, height: 30)
        transactionAmountMaxLabel.font = FontConfigManager.shared.getLabelFont()
        transactionAmountMaxLabel.text = LocalizedString("Fast", comment: "")
        scrollView.addSubview(transactionAmountMaxLabel)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: transactionAmountMinLabel.frame.maxY + 30)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: .UITextFieldTextDidChange, object: nil)
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        
        // Get the latest estimate gas price from Relay.
        // It's an async call.
        // If the api fails, gas price 10 will be returned.
        GasDataManager.shared.getEstimateGasPrice { (gasPrice, _) in
            self.gasPriceInGwei = Double(gasPrice)
            DispatchQueue.main.async {
                self.transactionAmountCurrentLabel.text = LocalizedString("gas price", comment: "") + ": \(self.gasPriceInGwei) gwei"
                self.updateTransactionFeeAmountLabel()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Update the transaction fee is needed. in SendCurrentAppWalletDataManager
        tokenSymbolLabel.text = asset.symbol
        let title = LocalizedString("Available Balance", comment: "")
        tokenTotalAmountLabel.text = "\(title) \(asset.display) \(asset.symbol)"
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()
    }
    
    func setResultOfAmount(with percentage: Double) {
        let length = Asset.getLength(of: asset.symbol) ?? 4
        let value = asset.balance * Double(percentage)
        amountTextField.text = value.withCommas(length)
        if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
            let total = value * price
            updateLabel(label: amountInfoLabel, text: total.currency, textColor: .black)
        }
        _ = validate()
    }
    
    @objc func pressedHelpButton(_ sender: Any) {
        let title = LocalizedString("What is gas?", comment: "")
        let message = LocalizedString("Gas is...", comment: "") // TODO
        let alertController = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .cancel, handler: { _ in
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        amountTextField.resignFirstResponder()
        self.view.endEditing(true)
        hideNumericKeyboard()
    }
    
    func updateLabel(label: UILabel, text: String, textColor: UIColor) {
        label.textColor = textColor
        label.text = text
        if textColor == .red {
            label.shake()
        }
    }
    
    func validateAddress() -> Bool {
        if let toAddress = addressTextField.text {
            if !toAddress.isEmpty {
                if toAddress.isHexAddress() {
                    var error: NSError? = nil
                    if GethNewAddressFromHex(toAddress, &error) != nil {
                        updateLabel(label: addressInfoLabel, text: LocalizedString("Please confirm the address before sending", comment: ""), textColor: .black)
                        return true
                    }
                }
                updateLabel(label: addressInfoLabel, text: LocalizedString("Please input a correct address", comment: ""), textColor: .red)
            } else {
                updateLabel(label: addressInfoLabel, text: LocalizedString("Please confirm the address before sending", comment: ""), textColor: .black)
            }
        }
        return false
    }
    
    func validateAmount() -> Bool {
        if let amount = Double(amountTextField.text ?? "0") {
            if amount > 0.0 {
                if asset.balance >= amount {
                    if let token = TokenDataManager.shared.getTokenBySymbol(asset!.symbol) {
                        if GethBigInt.generate(valueInEther: amount, symbol: token.symbol) != nil {
                            if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
                                let display = (amount * price).currency
                                updateLabel(label: amountInfoLabel, text: display, textColor: .black)
                                return true
                            }
                        }
                    }
                } else {
                    let title = LocalizedString("Available Balance", comment: "")
                    updateLabel(label: amountInfoLabel, text: "\(title) \(asset.display) \(asset.symbol)", textColor: .red)
                }
            } else {
                let text = LocalizedString("Please input a valid amount", comment: "")
                updateLabel(label: amountInfoLabel, text: text, textColor: .red)
            }
        } else {
            updateLabel(label: amountInfoLabel, text: 0.0.currency, textColor: .black)
        }
        return false
    }

    func validate() -> Bool {
        var isValid = false
        if activeTextFieldTag == addressTextField.tag {
            isValid = validateAddress()
        } else if activeTextFieldTag == amountTextField.tag {
            isValid = validateAmount()
        }
        return isValid
    }

    /*
    @objc func pressedAdvancedButton(_ sender: Any) {
        print("pressedAdvancedButton")
        showAdvanced = !showAdvanced
        if showAdvanced {
            UIView.animate(withDuration: 0.5, animations: {
                self.transactionSpeedSlider.alpha = 1
                self.transactionAmountMinLabel.alpha = 1
                self.transactionAmountCurrentLabel.alpha = 1
                self.transactionAmountMaxLabel.alpha = 1
                self.transactionAmountHelpButton.alpha = 1
            })
            // TODO: The position of the align icon is related to the size. So we use several hardcoded value here.
            self.advancedButton.setRightImage(imageName: "Arrow-button-down-light", imagePaddingTop: 0, imagePaddingLeft: 10, titlePaddingRight: 2)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.transactionSpeedSlider.alpha = 0
                self.transactionAmountMinLabel.alpha = 0
                self.transactionAmountCurrentLabel.alpha = 0
                self.transactionAmountMaxLabel.alpha = 0
                self.transactionAmountHelpButton.alpha = 0
            })
            self.advancedButton.setRightImage(imageName: "Arrow-button-right-light", imagePaddingTop: 0, imagePaddingLeft: 10, titlePaddingRight: 11)
        }
    }
    */
    
    func pushController() {
        let toAddress = addressTextField.text!
        if let token = TokenDataManager.shared.getTokenBySymbol(asset!.symbol) {
            let gethAmount = GethBigInt.generate(valueInEther: Double(amountTextField.text!)!, symbol: token.symbol)!
            var error: NSError? = nil
            let toAddress = GethNewAddressFromHex(toAddress, &error)!
            if token.symbol.uppercased() == "ETH" {
                SendCurrentAppWalletDataManager.shared._transferETH(amount: gethAmount, toAddress: toAddress, completion: completion)
            } else {
                // TODO: Error handling for invalid protocol value
                if !token.protocol_value.isHexAddress() {
                    print("token protocol \(token.protocol_value) is invalid")
                    return
                }
                let contractAddress = GethNewAddressFromHex(token.protocol_value, &error)!
                SendCurrentAppWalletDataManager.shared._transferToken(contractAddress: contractAddress, toAddress: toAddress, tokenAmount: gethAmount, completion: completion)
            }
        }
    }

    @IBAction func pressedSendButton(_ sender: Any) {
        print("start sending")
        // Show activity indicator
        start = Date()
        hideNumericKeyboard()
        addressTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        let isAmountValid = validateAmount()
        let isAddressValid = validateAddress()
        if isAmountValid && isAddressValid {
            SVProgressHUD.show(withStatus: LocalizedString("Processing the transaction", comment: "") + "...")
            self.pushController()
        }
        if !isAmountValid && amountInfoLabel.textColor != .red {
            amountInfoLabel.text = LocalizedString("Please input a valid amount", comment: "")
            amountInfoLabel.textColor = .red
            amountInfoLabel.shake()
        }
        if !isAddressValid && addressInfoLabel.textColor != .red {
            addressInfoLabel.text = LocalizedString("Please input a correct address", comment: "")
            addressInfoLabel.textColor = .red
            addressInfoLabel.shake()
        }
    }
    
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType) {
        print("value from scanning: \(valueSent)")
        addressTextField.text = valueSent
    }
    
    @objc func pressedScanButton(_ sender: Any) {
        let viewController = ScanQRCodeViewController()
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: UISlider.self) {
            return false
        }
        return true
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        print("Slider value changed \(sender.value)")
        let step: Float = 1
        let roundedStepValue = round(sender.value / step) * step
        gasPriceInGwei = Double(roundedStepValue)
        
        // Update info
        transactionAmountCurrentLabel.text = LocalizedString("gas price", comment: "") + ": \(roundedStepValue) gwei"
        updateTransactionFeeAmountLabel()
    }
    
    func updateTransactionFeeAmountLabel() {
        let amountInEther = gasPriceInGwei / 1000000000
        if let etherPrice = PriceDataManager.shared.getPrice(of: "ETH") {
            let transactionFeeInFiat = amountInEther * etherPrice * Double(GasDataManager.shared.getGasLimit(by: "eth_transfer")!)
            transactionFeeAmountLabel.text = "\(transactionFeeInFiat.currency)"
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            hideNumericKeyboard()
        } else if textField.tag == 1 {
            showNumericKeyboard(textField: amountTextField)
        }
        activeTextFieldTag = amountTextField.tag
        _ = validate()
        return true
    }
    
    func getActiveTextField() -> UITextField? {
        return amountTextField
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let systemKeyboardHeight = keyboardFrame.cgRectValue.height
        if #available(iOS 11.0, *) {
            // Get the the distance from the bottom safe area edge to the bottom of the screen
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0

            self.scrollViewButtonLayoutConstraint.constant = systemKeyboardHeight + 47 + 15*2 + bottomPadding
            self.sendButtonBackgroundViewBottomLayoutContraint.constant = systemKeyboardHeight

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                if self.addressY - self.scrollView.contentOffset.y < 0 || self.addressY - self.scrollView.contentOffset.y > self.scrollViewButtonLayoutConstraint.constant {
                    self.scrollView.setContentOffset(CGPoint.init(x: 0, y: self.addressY + 30), animated: true)
                }
            }, completion: { _ in

            })
        } else {
            sendButtonBackgroundViewBottomLayoutContraint.constant = systemKeyboardHeight
        }
        // self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        scrollViewButtonLayoutConstraint.constant = 47*UIStyleConfig.scale + 15*2

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            sendButtonBackgroundViewBottomLayoutContraint.constant = bottomPadding
        } else {
            sendButtonBackgroundViewBottomLayoutContraint.constant = 0
        }
    }
    
    @objc func keyboardDidChange(notification: NSNotification?) {
        activeTextFieldTag = addressTextField.tag
        _ = validate()
    }

    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            numericKeyboardView = DefaultNumericKeyboard.init(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate2 = self
            view.addSubview(numericKeyboardView)
            view.bringSubview(toFront: sendButtonBackgroundView)
            view.bringSubview(toFront: sendButton)
            
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            
            let destinateY = height - DefaultNumericKeyboard.height - sendButtonBackgroundViewHeightLayoutContraint.constant - bottomPadding
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                if self.amountY - self.scrollView.contentOffset.y < 0 || self.addressY - self.scrollView.contentOffset.y > self.scrollViewButtonLayoutConstraint.constant {
                    self.scrollView.setContentOffset(CGPoint.init(x: 0, y: self.amountY - 120*UIStyleConfig.scale), animated: true)
                }
                
            }, completion: { _ in
                self.isNumericKeyboardShow = true
                self.scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height + self.sendButtonBackgroundViewHeightLayoutContraint.constant
            })
        }
        numericKeyboardView.currentText = textField.text ?? ""
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            self.scrollViewButtonLayoutConstraint.constant = 0

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                // self.scrollView.setContentOffset(CGPoint.zero, animated: true)
            }, completion: { _ in
                self.isNumericKeyboardShow = false
            })
        } else {
            
        }
    }
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, currentTextDidUpdate currentText: String) {
        let activeTextField: UITextField? = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        activeTextField!.text = currentText
        _ = validate()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tokenTotalAmountLabel.frame.maxY < scrollView.contentOffset.y {
            self.navigationItem.title = "\(asset!.display) \(asset!.symbol) Available"
        } else {
            self.navigationItem.title = ""
        }
    }
}

extension SendAssetViewController {

    func completion(_ txHash: String?, _ error: Error?) {
        // Close activity indicator
        SVProgressHUD.dismiss()
        end = Date()
        let timeInterval1: Double = end.timeIntervalSince(start)
        print("Time to completion in _transfer: \(timeInterval1) seconds")
        
        guard error == nil && txHash != nil else {
            // Show toast
            DispatchQueue.main.async {                
                let title = LocalizedString("Failed to send the transaction", comment: "")
                let message = String(describing: error)
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizedString("Back", comment: ""), style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        print("Result of transfer is \(txHash!)")
        // Show toast
        DispatchQueue.main.async {
            let title = LocalizedString("Sent the transaction successfully", comment: "")
            let message = "Result of transfer is \(txHash!)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString("OK", comment: ""), style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
