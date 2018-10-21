//
//  ConvertETHViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import NotificationBannerSwift

class ConvertETHViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tokenSImageView: UIImageView!
    @IBOutlet weak var tokenBImageView: UIImageView!
    @IBOutlet weak var amountSTextField: UITextField!
    @IBOutlet weak var tokenSLabel: UILabel!
    @IBOutlet weak var amountBTextField: UITextField!
    @IBOutlet weak var tokenBLabel: UILabel!
    @IBOutlet weak var swapTokenButton: UIButton!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var gasInfoLabel: UILabel!
    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var convertButton: GradientButton!
    
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    // Mask view
    var blurVisualEffectView = UIView(frame: .zero)

    // Drag down to close a present view controller.
    var dismissInteractor = MiniToLargeViewInteractive()

    // Default values
    var asset: Asset? = CurrentAppWalletDataManager.shared.getAsset(symbol: "ETH")
    var tipMessage: String = ""
    
    // Numeric Keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("Convert", comment: "")
        
        contentView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        contentView.applyShadow()
        
        tokenSImageView.image = asset?.icon
        tokenBImageView.image = getAnotherAsset()?.icon
        
        amountSTextField.delegate = self
        amountSTextField.tintColor = .black
        amountSTextField.inputView = UIView(frame: .zero)
        amountSTextField.text = "0"
        
        amountBTextField.delegate = self
        amountBTextField.tintColor = .black
        amountBTextField.inputView = UIView(frame: .zero)
        amountBTextField.text = "0"
        
        tokenSLabel.textColor = UIColor.init(rgba: "#F8F9FA").withAlphaComponent(0.6)
        tokenSLabel.font = FontConfigManager.shared.getMediumFont(size: 13)
        tokenBLabel.textColor = UIColor.init(rgba: "#F8F9FA").withAlphaComponent(0.6)
        tokenBLabel.font = FontConfigManager.shared.getMediumFont(size: 13)
        
        swapTokenButton.addTarget(self, action: #selector(pressedArrowButton), for: .touchUpInside)
        tokenSImageView.isUserInteractionEnabled = true
        tokenSImageView.addGestureRecognizer(setSwapTokenGestureRecognizer())
        tokenBImageView.isUserInteractionEnabled = true
        tokenBImageView.addGestureRecognizer(setSwapTokenGestureRecognizer())
        tokenSLabel.isUserInteractionEnabled = true
        tokenSLabel.addGestureRecognizer(setSwapTokenGestureRecognizer())
        tokenBLabel.isUserInteractionEnabled = true
        tokenBLabel.addGestureRecognizer(setSwapTokenGestureRecognizer())
        
        availableLabel.setSubTitleCharFont()
        maxButton.titleLabel?.setSubTitleCharFont()
        maxButton.title = LocalizedString("Max", comment: "")
        maxButton.setTitleColor(UIColor.theme, for: .normal)
        maxButton.setTitleColor(UIColor.theme.withAlphaComponent(0.6), for: .highlighted)

        gasTipLabel.setTitleCharFont()
        gasTipLabel.text = LocalizedString("Tx Fee Limit", comment: "")
        gasTipLabel.isUserInteractionEnabled = true
        let transactionFeeLabelTap = UITapGestureRecognizer(target: self, action: #selector(pressedAdvancedButton))
        transactionFeeLabelTap.numberOfTapsRequired = 1
        gasTipLabel.addGestureRecognizer(transactionFeeLabelTap)
        
        gasInfoLabel.setTitleCharFont()
        gasInfoLabel.textAlignment = .right
        updateTransactionFeeAmountLabel()
        gasInfoLabel.isUserInteractionEnabled = true
        let transactionFeeAmountLabelTap = UITapGestureRecognizer(target: self, action: #selector(pressedAdvancedButton))
        transactionFeeAmountLabelTap.numberOfTapsRequired = 1
        gasInfoLabel.addGestureRecognizer(transactionFeeAmountLabelTap)
        
        advancedButton.addTarget(self, action: #selector(pressedAdvancedButton), for: .touchUpInside)
        
        infoLabel1.font = FontConfigManager.shared.getCharactorFont(size: 11)
        infoLabel1.theme_textColor = ["#00000099", "#ffffff66"]
        infoLabel1.text = LocalizedString("Convert_DES", comment: "")
        
        infoLabel2.font = FontConfigManager.shared.getCharactorFont(size: 11)
        infoLabel2.theme_textColor = ["#00000099", "#ffffff66"]
        infoLabel2.text = LocalizedString("Convert_TIP", comment: "")

        convertButton.title = LocalizedString("Convert", comment: "")
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollViewBottomConstraint.constant = 0
        
        GasDataManager.shared.getEstimateGasPrice { (gasPrice, _) in
            self.gasPriceInGwei = Double(gasPrice)
            DispatchQueue.main.async {
                self.updateTransactionFeeAmountLabel()
            }
        }
        
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
        self.update()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: infoLabel2.frame.maxY+20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateTransactionFeeAmountLabel() {
        let amountInEther = gasPriceInGwei / 1000000000
        if let etherPrice = PriceDataManager.shared.getPrice(of: "ETH") {
            let amont = amountInEther * Double(GasDataManager.shared.getGasLimit(by: "token_transfer")!)
            let transactionFeeInFiat = amont * etherPrice
            gasInfoLabel.text = "\(amont.withCommas(6)) ETH ≈ \(transactionFeeInFiat.currency)"
        }
    }
    
    func update() {
        if let asset = self.asset {
            let symbol = asset.symbol
            let available = ConvertDataManager.shared.getMaxAmount(symbol: symbol)
            let title = LocalizedString("Available Balance", comment: "")
            self.tipMessage = "\(title) \(available.withCommas(6)) \(symbol)"
            availableLabel.text = self.tipMessage
            if symbol == "ETH" {
                tokenSLabel.text = "ETH"
                tokenBLabel.text = "WETH"
                infoLabel2.isHidden = false
            } else if symbol == "WETH" {
                tokenSLabel.text = "WETH"
                tokenBLabel.text = "ETH"
                infoLabel2.isHidden = true
            }
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        amountSTextField.resignFirstResponder()
        self.view.endEditing(true)
        hideNumericKeyboard()
    }
    
    func getAnotherToken() -> String {
        if let asset = self.asset {
            if asset.symbol.uppercased() == "ETH" {
                return "WETH"
            } else if asset.symbol.uppercased() == "WETH" {
                return "ETH"
            }
        }
        return "WETH"
    }
    
    func getAnotherAsset() -> Asset? {
        let symbol = getAnotherToken()
        return ConvertDataManager.shared.getAsset(by: symbol)
    }
    
    @objc func pressedArrowButton() {
        if let asset = self.asset {
            self.asset = getAnotherAsset()
            UIView.transition(with: tokenSImageView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tokenSImageView.image = self.asset?.icon; self.tokenBImageView.image = asset.icon }, completion: nil)
            UIView.transition(with: tokenBImageView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tokenBImageView.image = asset.icon }, completion: nil)
            update()
            _ = validate()
        }
    }
    
    func setSwapTokenGestureRecognizer() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressedArrowButton))
        tap.numberOfTapsRequired = 1
        return tap
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountSTextField.becomeFirstResponder() //Optional
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        showNumericKeyboard(textField: textField)
        if amountSTextField.text == "0" {
            amountSTextField.text = ""
            amountBTextField.text = ""
        }
        return true
    }

    func getActiveTextField() -> UITextField? {
        // Only one text field in the view controller.
        return amountSTextField
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            scrollViewBottomConstraint.constant = DefaultNumericKeyboard.height
            view.addSubview(numericKeyboardView)
            
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            let destinateY = height - DefaultNumericKeyboard.height - bottomPadding
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                self.scrollView.setContentOffset(CGPoint.zero, animated: false)
            }, completion: { _ in
                self.isNumericKeyboardShow = true
            })
        }
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            self.scrollViewBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { _ in
                self.isNumericKeyboardShow = false
            })
        }
    }

    func completion(_ txHash: String?, _ error: Error?) {
        guard error == nil && txHash != nil else {
            DispatchQueue.main.async {
                let title = LocalizedString("Convert_Fail_Tip", comment: "")
                let banner = NotificationBanner.generate(title: title, style: .danger)
                banner.duration = 3
                banner.show()
            }
            return
        }
        print("Result of transfer is \(txHash!)")
        DispatchQueue.main.async {
            let title = LocalizedString("Convert_Success_Tip", comment: "")
            let banner = NotificationBanner.generate(title: "\(title) \(txHash!)", style: .success)
            banner.duration = 3
            banner.show()
        }
    }
    
    func validate() -> GethBigInt? {
        var result: GethBigInt?
        if let text = amountSTextField.text,
            let inputAmount = Double(text), let maxAmount = asset?.balance {
            if inputAmount > 0 {
                if inputAmount > maxAmount {
                    availableLabel.shake()
                    availableLabel.textColor = .fail
                    availableLabel.text = self.tipMessage
                } else {
                    amountBTextField.text = amountSTextField.text
                    result = GethBigInt.generate(inputAmount)
                    availableLabel.textColor = UIColor.text1
                    availableLabel.text = PriceDataManager.shared.getPrice(of: asset!.symbol, by: inputAmount)
                }
            } else {
                availableLabel.shake()
                availableLabel.textColor = .fail
                availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            }
        } else {
            if amountSTextField.text == "" {
                availableLabel.text = self.tipMessage
                availableLabel.textColor = UIColor.text1
                amountBTextField.text = ""
            } else {
                availableLabel.textColor = .fail
                availableLabel.shake()
                availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            }
        }
        return result
    }
    
    @IBAction func pressedMaxButton(_ sender: UIButton) {
        if let asset = self.asset {
            let amount = ConvertDataManager.shared.getMaxAmountString(asset.symbol)
            amountSTextField.text = amount
            amountBTextField.text = amount
            _ = validate()
        }
    }
    
    @objc func pressedAdvancedButton() {
        let vc = SetGasViewController()
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
    
    @IBAction func pressedConvertButton(_ sender: Any) {
        guard validate() != nil else {
            availableLabel.textColor = .fail
            availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            availableLabel.shake()
            return
        }
        let vc = ConvertETHConfirmViewController()
        // vc.transitioningDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        
        vc.convertAsset = self.asset
        vc.otherAsset = self.getAnotherAsset()
        vc.convertAmount = self.amountSTextField.text
        vc.gasAmountText = self.gasInfoLabel.text
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

    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        
        let activeTextField: UITextField? = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        var currentText = activeTextField!.text ?? ""
        switch (position.row, position.column) {
        case (3, 0):
            if !currentText.contains(".") {
                currentText += "."
                // TODO: add a shake animation to the item at (3, 0)
            }
            activeTextField!.text = currentText
        case (3, 1):
            activeTextField!.text = currentText + "0"
        case (3, 2):
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
            activeTextField!.text = currentText
        default:
            let itemValue = position.row * 3 + position.column + 1
            activeTextField!.text = currentText + String(itemValue)
        }
        update()
        _ = validate()
    }
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemLongPressed item: NumericKeyboardItem, atPosition position: Position) {
        print("Long pressed keyboard: (\(position.row), \(position.column))")
        let activeTextField = getActiveTextField()
        guard activeTextField != nil else {
            return
        }
        var currentText = activeTextField!.text ?? ""
        if (position.row, position.column) == (3, 2) {
            if currentText.count > 0 {
                currentText = String(currentText.dropLast())
            }
            activeTextField!.text = currentText
        }
    }
}

extension ConvertETHViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.transitionType = .Dismiss
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractor
    }

}
