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
import StepSlider

class SendAssetViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, DefaultNumericKeyboardDelegate, NumericKeyboardProtocol, QRCodeScanProtocol, StepSliderDelegate {
    
    // Header
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var tokenHeaderLabel: UILabel!
    @IBOutlet weak var tokenTotalAmountLabel: UILabel!
    
    // Content
    @IBOutlet weak var contentView: UIView!
    
    // Address
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var addressInfoLabel: UILabel!
    
    // Amount
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var amountInfoLabel: UILabel!
    @IBOutlet weak var transactionFeeTipLabel: UILabel!
    
    // Transaction info
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionFeeAmountLabel: UILabel!
    @IBOutlet weak var advancedButton: UIButton!

    // Send button
    @IBOutlet weak var sendButton: UIButton!
    
    // Scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    // Mask view
    @IBOutlet weak var totalMaskView: UIView!
    
    // slider
    var stepSlider: StepSlider = StepSlider()
    
    // Numeric keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    var activeTextFieldTag = -1
    
    var asset: Asset!
    var address: String!
    
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setBackButton()
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        // First row: token
        headerButton.theme_setBackgroundImage(GlobalPicker.button, forState: .normal)
        headerButton.theme_setBackgroundImage(GlobalPicker.buttonHighlight, forState: .highlighted)
        tokenIconImageView.image = UIImage(named: "ETH")
        tokenHeaderLabel.setTitleDigitFont()
        tokenTotalAmountLabel.textAlignment = .right
        tokenTotalAmountLabel.setTitleDigitFont()
        
        // Second row: address
        addressInfoLabel.setTitleCharFont()
        addressInfoLabel.text = LocalizedString("Please confirm the address before sending", comment: "")
        
        addressTextField.delegate = self
        addressTextField.tag = 0
        addressTextField.keyboardType = .alphabet
        addressTextField.font = FontConfigManager.shared.getDigitalFont()
        addressTextField.theme_tintColor = GlobalPicker.contrastTextColor
        addressTextField.placeholder = LocalizedString("Enter the address", comment: "")
        addressTextField.text = self.address ?? ""
        addressTextField.contentMode = UIViewContentMode.bottom
        addressTextField.setLeftPaddingPoints(8)
        addressTextField.setRightPaddingPoints(32)
        
        // Third row: Amount
        amountInfoLabel.setTitleCharFont()
        amountInfoLabel.text = 0.0.currency
        
        amountTextField.delegate = self
        amountTextField.inputView = UIView()
        amountTextField.tag = 1
        amountTextField.font = FontConfigManager.shared.getDigitalFont()
        amountTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountTextField.placeholder = LocalizedString("Enter the amount", comment: "")
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.setLeftPaddingPoints(8)
        amountTextField.setRightPaddingPoints(40)

        tokenSymbolLabel.font = FontConfigManager.shared.getLightFont()
        tokenSymbolLabel.theme_textColor = GlobalPicker.contrastTextColor
        tokenSymbolLabel.textAlignment = .right
        
        transactionFeeTipLabel.setSubTitleCharFont()
        transactionFeeTipLabel.text = LocalizedString("ETH_TIP", comment: "")

        // Transaction
        transactionFeeLabel.setTitleCharFont()
        transactionFeeLabel.text = LocalizedString("Transaction Fee", comment: "")
        
        transactionFeeAmountLabel.setTitleCharFont()
        transactionFeeAmountLabel.textAlignment = .right
        transactionFeeAmountLabel.text = ""
        updateTransactionFeeAmountLabel()
        
        scrollView.delegate = self

        // Send button
        sendButton.title = LocalizedString("Send", comment: "")
        sendButton.setupSecondary()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: .UITextFieldTextDidChange, object: nil)

        GasDataManager.shared.getEstimateGasPrice { (gasPrice, _) in
            self.gasPriceInGwei = Double(gasPrice)
            DispatchQueue.main.async {
                self.updateTransactionFeeAmountLabel()
            }
        }
        
        // TODO: unable to add StepSlider in xib. Have to add it here.
        // We also have made some modifications in our repo.
        // https://github.com/xiaowheat/StepSlider
        stepSlider = StepSlider.init(frame: CGRect(x: 10, y: amountTextField.bottomY + 16, width: contentView.width - 10 * 2, height: 44))
        stepSlider.delegate = self
        stepSlider.maxCount = 4
        stepSlider.setIndex(2, animated: false)
        stepSlider.labelFont = FontConfigManager.shared.getRegularFont(size: 12)
        stepSlider.labelColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.labels = ["0%", "25%", "50%", "75%", "100%"]
        stepSlider.trackHeight = 2
        stepSlider.trackCircleRadius = 3
        stepSlider.trackColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.tintColor = UIColor.themeGreen
        stepSlider.sliderCircleRadius = 10
        stepSlider.sliderCircleColor = UIColor.themeGreen
        stepSlider.labelOffset = 10
        stepSlider.isDotsInteractionEnabled = true
        stepSlider.adjustLabel = true
        contentView.addSubview(stepSlider)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Update the transaction fee is needed. in SendCurrentAppWalletDataManager
        let symbol = SendCurrentAppWalletDataManager.shared.token?.symbol ?? "ETH"
        asset = CurrentAppWalletDataManager.shared.getAsset(symbol: symbol)

        tokenIconImageView.image = asset.icon
        tokenHeaderLabel.text = asset.symbol
        tokenTotalAmountLabel.text = "\(asset.display) \(asset.symbol)"
        tokenSymbolLabel.text = asset.symbol
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()
        if asset.symbol.uppercased() == "ETH" {
            transactionFeeTipLabel.isHidden = false
        } else {
            transactionFeeTipLabel.isHidden = true
        }
    }
    
    @IBAction func pressedHeaderButton(_ sender: UIButton) {
        let vc = TokenSelectTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setResultOfAmount(with percentage: Double) {
        let length = Asset.getLength(of: asset.symbol) ?? 4
        let value = asset.balance * Double(percentage)
        amountTextField.text = value.withCommas(length)
        if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
            let total = value * price
            updateLabel(label: amountInfoLabel, text: total.currency, textColor: .text1)
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
        if textColor == .fail {
            label.shake()
        }
    }
    
    func validateAddress() -> Bool {
        if let toAddress = addressTextField.text {
            if !toAddress.isEmpty {
                if toAddress.isHexAddress() {
                    var error: NSError? = nil
                    if GethNewAddressFromHex(toAddress, &error) != nil {
                        updateLabel(label: addressInfoLabel, text: LocalizedString("Please confirm the address before sending", comment: ""), textColor: .text1)
                        return true
                    }
                }
                updateLabel(label: addressInfoLabel, text: LocalizedString("Please input a correct address", comment: ""), textColor: .fail)
            } else {
                updateLabel(label: addressInfoLabel, text: LocalizedString("Please confirm the address before sending", comment: ""), textColor: .text1)
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
                                updateLabel(label: amountInfoLabel, text: display, textColor: .text1)
                                return true
                            }
                        }
                    }
                } else {
                    let title = LocalizedString("Available Balance", comment: "")
                    updateLabel(label: amountInfoLabel, text: "\(title) \(asset.display) \(asset.symbol)", textColor: .fail)
                }
            } else {
                let text = LocalizedString("Please input a valid amount", comment: "")
                updateLabel(label: amountInfoLabel, text: text, textColor: .fail)
            }
        } else {
            updateLabel(label: amountInfoLabel, text: 0.0.currency, textColor: .text1)
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
    
    @IBAction func pressedAdvancedButton(_ sender: UIButton) {
        self.totalMaskView.alpha = 0.75
        let vc = SetGasViewController()
        vc.recGasPriceInGwei = self.gasPriceInGwei
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        vc.dismissClosure = {
            self.totalMaskView.alpha = 0
            self.gasPriceInGwei = vc.gasPriceInGwei
        }
        self.present(vc, animated: true, completion: nil)
    }
    
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
        hideNumericKeyboard()
        addressTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        let isAmountValid = validateAmount()
        let isAddressValid = validateAddress()
        if isAmountValid && isAddressValid {
            SVProgressHUD.show(withStatus: LocalizedString("Processing the transaction", comment: "") + "...")
            self.pushController()
        }
        if !isAmountValid && amountInfoLabel.textColor != .fail {
            amountInfoLabel.text = LocalizedString("Please input a valid amount", comment: "")
            amountInfoLabel.textColor = .fail
            amountInfoLabel.shake()
        }
        if !isAddressValid && addressInfoLabel.textColor != .fail {
            addressInfoLabel.text = LocalizedString("Please input a correct address", comment: "")
            addressInfoLabel.textColor = .fail
            addressInfoLabel.shake()
        }
    }
    
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType) {
        print("value from scanning: \(valueSent)")
        addressTextField.text = valueSent
    }
    
    @IBAction func pressedScanButton(_ sender: UIButton) {
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
        updateTransactionFeeAmountLabel()
    }
    
    func updateTransactionFeeAmountLabel() {
        let amountInEther = gasPriceInGwei / 1000000000
        if let etherPrice = PriceDataManager.shared.getPrice(of: "ETH") {
            let amont = amountInEther * Double(GasDataManager.shared.getGasLimit(by: "token_transfer")!)
            let transactionFeeInFiat = amont * etherPrice
            transactionFeeAmountLabel.text = "\(amont.withCommas(6)) ETH ≈ \(transactionFeeInFiat.currency)"
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
            self.scrollViewButtonLayoutConstraint.constant = systemKeyboardHeight - bottomPadding
            let addressY = addressTextField.frame.minY
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                if addressY - self.scrollView.contentOffset.y < 0 || addressY - self.scrollView.contentOffset.y > self.scrollViewButtonLayoutConstraint.constant {
                    self.scrollView.setContentOffset(CGPoint.init(x: 0, y: addressY + 30), animated: true)
                }
            }, completion: { _ in
                self.activeTextFieldTag = self.addressTextField.tag
            })
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")

        if self.activeTextFieldTag != 1 {
            scrollViewButtonLayoutConstraint.constant = 0
        }
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
//            sendButtonBackgroundViewBottomLayoutContraint.constant = bottomPadding
//        } else {
//            sendButtonBackgroundViewBottomLayoutContraint.constant = 0
//        }
    }
    
    @objc func keyboardDidChange(notification: NSNotification?) {
//        activeTextFieldTag = addressTextField.tag
        _ = validate()
    }

    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            numericKeyboardView = DefaultNumericKeyboard.init(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate2 = self
            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            view.addSubview(numericKeyboardView)
//            view.bringSubview(toFront: sendButtonBackgroundView)
//            view.bringSubview(toFront: sendButton)
            
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            let amountY = amountTextField.frame.minY
            let addressY = addressTextField.frame.minY
            let destinateY = height - DefaultNumericKeyboard.height - bottomPadding
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                if amountY - self.scrollView.contentOffset.y < 0 || addressY - self.scrollView.contentOffset.y > self.scrollViewButtonLayoutConstraint.constant {
                    self.scrollView.setContentOffset(CGPoint.init(x: 0, y: amountY - 120*UIStyleConfig.scale), animated: true)
                }
            }, completion: { _ in
                self.isNumericKeyboardShow = true
//                self.scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height + self.sendButtonBackgroundViewHeightLayoutContraint.constant
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
    
    func stepSliderValueChanged(_ value: Double) {
        // valud is from 0.0 - 1.0
        print(value)
    }
}

extension SendAssetViewController {

    func completion(_ txHash: String?, _ error: Error?) {
        // Close activity indicator
        SVProgressHUD.dismiss()
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
