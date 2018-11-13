//
//  SendAssetViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import StepSlider

class SendAssetViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, DefaultNumericKeyboardDelegate, NumericKeyboardProtocol, QRCodeScanProtocol, StepSliderDelegate {
    
    // Header
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var iconView: IconView!

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
    @IBOutlet weak var sendButton: GradientButton!
    
    // Scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    // Mask view
    var blurVisualEffectView = UIView(frame: .zero)
    
    // Drag down to close a present view controller.
    var dismissInteractor = MiniToLargeViewInteractive()
    
    // slider
    var stepSlider: StepSlider = StepSlider.getDefault()
    
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
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Send", comment: "")
        
        contentView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        contentView.applyShadow()
        
        // First row: token
        headerButton.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        headerButton.theme_setBackgroundImage(ColorPicker.buttonSelected, forState: .highlighted)
        
        tokenIconImageView.image = UIImage(named: "ETH")
        iconView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        tokenHeaderLabel.setTitleDigitFont()
        tokenTotalAmountLabel.textAlignment = .right
        tokenTotalAmountLabel.setTitleDigitFont()
        
        // Second row: address
        addressInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        addressInfoLabel.theme_textColor = GlobalPicker.textLightColor
        addressInfoLabel.text = LocalizedString("Please confirm the address before sending", comment: "")
        
        addressTextField.delegate = self
        addressTextField.tag = 0
        addressTextField.keyboardType = .alphabet
        addressTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        addressTextField.font = FontConfigManager.shared.getDigitalFont()
        addressTextField.theme_tintColor = GlobalPicker.contrastTextColor
        addressTextField.placeholder = LocalizedString("Enter the address", comment: "")
        addressTextField.text = self.address ?? ""
        addressTextField.contentMode = UIViewContentMode.bottom
        addressTextField.setLeftPaddingPoints(8)
        addressTextField.setRightPaddingPoints(32)
        
        // Third row: Amount
        amountInfoLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        amountInfoLabel.theme_textColor = GlobalPicker.textLightColor
        amountInfoLabel.text = 0.0.currency
        
        amountTextField.delegate = self
        amountTextField.inputView = UIView(frame: .zero)
        amountTextField.tag = 1
        amountTextField.font = FontConfigManager.shared.getDigitalFont()
        amountTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountTextField.placeholder = LocalizedString("Enter the amount", comment: "")
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.setLeftPaddingPoints(8)
        amountTextField.setRightPaddingPoints(40)

        tokenSymbolLabel.font = FontConfigManager.shared.getMediumFont()
        tokenSymbolLabel.theme_textColor = GlobalPicker.contrastTextColor
        tokenSymbolLabel.textAlignment = .right

        transactionFeeTipLabel.font = FontConfigManager.shared.getRegularFont(size: 11)
        transactionFeeTipLabel.theme_textColor = GlobalPicker.textLightColor
        transactionFeeTipLabel.text = LocalizedString("ETH_TIP", comment: "")

        // Transaction
        transactionFeeLabel.setTitleCharFont()
        transactionFeeLabel.text = LocalizedString("Tx Fee Limit", comment: "")
        transactionFeeLabel.isUserInteractionEnabled = true
        let transactionFeeLabelTap = UITapGestureRecognizer(target: self, action: #selector(pressedAdvancedButton))
        transactionFeeLabelTap.numberOfTapsRequired = 1
        transactionFeeLabel.addGestureRecognizer(transactionFeeLabelTap)
        
        transactionFeeAmountLabel.setTitleCharFont()
        transactionFeeAmountLabel.textAlignment = .right

        transactionFeeAmountLabel.isUserInteractionEnabled = true
        let transactionFeeAmountLabelTap = UITapGestureRecognizer(target: self, action: #selector(pressedAdvancedButton))
        transactionFeeAmountLabelTap.numberOfTapsRequired = 1
        transactionFeeAmountLabel.addGestureRecognizer(transactionFeeAmountLabelTap)

        advancedButton.addTarget(self, action: #selector(pressedAdvancedButton), for: .touchUpInside)
        
        scrollView.delegate = self
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.delaysContentTouches = false

        // Send button
        sendButton.title = LocalizedString("Send", comment: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: .UITextFieldTextDidChange, object: nil)

        GasDataManager.shared.getEstimateGasPrice { (gasPrice, _) in
            self.gasPriceInGwei = Double(gasPrice)
            DispatchQueue.main.async {
                self.updateTransactionFeeAmountLabel()
            }
        }
        
        let width = UIScreen.main.bounds.width - 15*4
        stepSlider.frame = CGRect(x: 15, y: amountInfoLabel.bottomY + 15, width: width, height: 20)
        stepSlider.delegate = self
        stepSlider.maxCount = 4
        stepSlider.setIndex(0, animated: false)
        stepSlider.labels = ["0%", "25%", "50%", "75%", "100%"]
        contentView.addSubview(stepSlider)
        
        blurVisualEffectView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        blurVisualEffectView.alpha = 1
        blurVisualEffectView.frame = UIScreen.main.bounds
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
        updateTransactionFeeAmountLabel()

        if let asset = self.asset {
            if asset.icon != nil {
                tokenIconImageView.image = asset.icon
                tokenIconImageView.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = asset.symbol
                iconView.symbolLabel.text = asset.symbol
                tokenIconImageView.isHidden = true
            }
            tokenHeaderLabel.text = asset.symbol
            tokenTotalAmountLabel.text = "\(asset.display) \(asset.symbol)"
            tokenSymbolLabel.text = asset.symbol
            if asset.symbol.uppercased() == "ETH" {
                transactionFeeTipLabel.isHidden = false
            } else {
                transactionFeeTipLabel.isHidden = true
            }
            
            CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.getNonceFromEthereum(completionHandler: {})
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set contentSize
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 600)
    }
    
    @IBAction func pressedHeaderButton(_ sender: UIButton) {
        let vc = TokenSelectTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
                    var error: NSError?
                    if GethNewAddressFromHex(toAddress, &error) != nil {
                        updateLabel(label: addressInfoLabel, text: LocalizedString("Please confirm the address before sending", comment: ""), textColor: .text2)
                        return true
                    }
                }
                updateLabel(label: addressInfoLabel, text: LocalizedString("Please input a correct address", comment: ""), textColor: .fail)
            } else {
                updateLabel(label: addressInfoLabel, text: LocalizedString("Please confirm the address before sending", comment: ""), textColor: .text2)
            }
        }
        return false
    }
    
    func getAvailableAmount() -> Double {
        var result: Double = 0
        if let asset = self.asset {
            let balance = asset.balance
            if asset.symbol.uppercased() == "ETH" {
                result = balance - 0.01
            } else {
                result = balance
            }
        }
        return result < 0 ? 0 : result
    }
    
    func getAvailableString() -> String {
        var result: String = ""
        if let asset = self.asset {
            if asset.symbol.uppercased() == "ETH" {
                var balance = asset.balance - 0.01
                if balance < 0 {
                    balance = 0
                }
                result = balance.withCommas(6)
            } else {
                result = asset.display
            }
        }
        return result
    }
    
    func validateAmount() -> Bool {
        if let amount = Double(amountTextField.text ?? "0") {
            if amount > 0.0 {
                if asset.balance >= amount {
                    if let token = TokenDataManager.shared.getTokenBySymbol(asset!.symbol) {
                        if GethBigInt.generate(valueInEther: amount, symbol: token.symbol) != nil {
                            if let price = PriceDataManager.shared.getPrice(of: asset.symbol) {
                                let display = (amount * price).currency
                                updateLabel(label: amountInfoLabel, text: display, textColor: .text2)
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
            updateLabel(label: amountInfoLabel, text: 0.0.currency, textColor: .text2)
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
    
    @objc func pressedAdvancedButton() {
        let vc = SetGasViewController()
        if asset.symbol == "ETH" {
            vc.gasLimitType = "eth_transfer"
        } else {
            vc.gasLimitType = "token_transfer"
        }
        // vc.transitioningDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.dismissClosure = {
            self.gasPriceInGwei = GasDataManager.shared.getGasPriceInGwei()
            self.updateTransactionFeeAmountLabel()

            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: {(_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
        }
        
        dismissInteractor.percentThreshold = 0.2
        dismissInteractor.dismissClosure = {
            self.gasPriceInGwei = GasDataManager.shared.getGasPriceInGwei()
            self.updateTransactionFeeAmountLabel()
        }
        
        self.present(vc, animated: true) {
            // self.dismissInteractor.attachToViewController(viewController: vc, withView: vc.headerView, presentViewController: nil, backgroundView: self.blurVisualEffectView)
        }
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
    }
    
    func pushController() {
        let vc = SendConfirmViewController()
        // vc.transitioningDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        
        vc.sendAsset = self.asset
        vc.sendAmount = self.amountTextField.text
        vc.receiveAddress = self.addressTextField.text
        vc.gasAmountText = self.transactionFeeAmountLabel.text
        vc.parentNavController = self.navigationController
        vc.dismissClosure = {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurVisualEffectView.alpha = 0.0
            }, completion: {(_) in
                self.blurVisualEffectView.removeFromSuperview()
            })
        }

        dismissInteractor.percentThreshold = 0.4
        dismissInteractor.dismissClosure = {
        }
        
        self.present(vc, animated: true) {
            // self.dismissInteractor.attachToViewController(viewController: vc, withView: vc.view, presentViewController: nil, backgroundView: self.blurVisualEffectView)
        }
        
        self.navigationController?.view.addSubview(self.blurVisualEffectView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurVisualEffectView.alpha = 1.0
        }, completion: {(_) in
            
        })
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
            let gasLimit: Int64
            if asset.symbol == "ETH" {
                gasLimit = GasDataManager.shared.getGasLimit(by: "eth_transfer")!
            } else {
                gasLimit = GasDataManager.shared.getGasLimit(by: "token_transfer")!
            }
            let amount = amountInEther * Double(gasLimit)
            let transactionFeeInFiat = amount * etherPrice
            transactionFeeAmountLabel.text = "\(amount.withCommas(6)) ETH ≈ \(transactionFeeInFiat.currency)"
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
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")

        if self.activeTextFieldTag != 1 {
            scrollViewButtonLayoutConstraint.constant = 0
        }
    }
    
    @objc func keyboardDidChange(notification: NSNotification?) {
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
            self.navigationItem.title = LocalizedString("Send", comment: "")
        }
    }
    
    func stepSliderValueChanged(_ value: Double) {
        let amount = (self.getAvailableAmount() * value)
        amountTextField.text = "\(amount.withCommas(6))"
        activeTextFieldTag = amountTextField.tag
        _ = validate()
    }
}

extension SendAssetViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.transitionType = .Dismiss
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }
    
}
