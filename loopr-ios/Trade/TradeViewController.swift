//
//  TradeBuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextBackgroundView: UIView!
    @IBOutlet weak var nextButton: UIButton!

    // TokenS
    var tokenSButton: UIButton = UIButton()
    var amountSellTextField: UITextField = UITextField()
    var tokenSUnderLine: UIView = UIView()
    var estimateValueInCurrency: UILabel = UILabel()
    var maxButton: UIButton = UIButton()
    
    // Exchange label
    var exchangeImage: UIImageView = UIImageView()
    var exchangeLabel: UILabel = UILabel()
    
    // TokenB
    var tokenBButton: UIButton = UIButton()
    var amountBuyTextField: UITextField = UITextField()
    var totalUnderLine: UIView = UIView()
    var availableLabel: UILabel = UILabel()

    // Numeric keyboard
    var isNumericKeyboardShown: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!

    var activeTextFieldTag = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollViewButtonLayoutConstraint.constant = 0
        self.navigationItem.title = NSLocalizedString("Trade", comment: "")
        
        let qrScanButton = UIButton(type: UIButtonType.custom)
        // TODO: smaller images.
        qrScanButton.theme_setImage(["Scan", "Scan-white"], forState: UIControlState.normal)
        qrScanButton.setImage(UIImage(named: "Scan")?.alpha(0.3), for: .highlighted)
        qrScanButton.addTarget(self, action: #selector(self.pressQRCodeButton(_:)), for: UIControlEvents.touchUpInside)
        qrScanButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let qrCodeBarButton = UIBarButtonItem(customView: qrScanButton)
        self.navigationItem.leftBarButtonItem = qrCodeBarButton
        
        let historyButton = UIButton(type: UIButtonType.custom)
        // TODO: smaller images.
        historyButton.theme_setImage(["Order-history-black", "Order-history-white"], forState: UIControlState.normal)
        historyButton.setImage(UIImage(named: "Order-history-black")?.alpha(0.3), for: .highlighted)
        historyButton.addTarget(self, action: #selector(self.pressQRCodeButton(_:)), for: UIControlEvents.touchUpInside)
        historyButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let historyBarButton = UIBarButtonItem(customView: historyButton)
        self.navigationItem.rightBarButtonItem = historyBarButton
        
        nextButton.title = NSLocalizedString("Next", comment: "")
        nextButton.setupRoundBlack()
        nextButton.isEnabled = false
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        let originY: CGFloat = 60
        let padding: CGFloat = 15
        let tokenButtonWidth: CGFloat = 60

        // First row: TokenS
        
        tokenSButton.setTitleColor(UIColor.black, for: .normal)
        tokenSButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        tokenSButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        tokenSButton.frame = CGRect(x: screenWidth-padding-tokenButtonWidth, y: originY, width: tokenButtonWidth, height: 40)
        tokenSButton.addTarget(self, action: #selector(pressedSwitchTokenSButton), for: .touchUpInside)
        scrollView.addSubview(tokenSButton)
        
        amountSellTextField.delegate = self
        amountSellTextField.tag = 0
        amountSellTextField.inputView = UIView()
        amountSellTextField.font = FontConfigManager.shared.getLabelFont()
        amountSellTextField.theme_tintColor = GlobalPicker.textColor
        amountSellTextField.placeholder = NSLocalizedString("Enter the amount you have", comment: "")
        amountSellTextField.contentMode = UIViewContentMode.bottom
        amountSellTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountSellTextField)
        
        tokenSUnderLine.frame = CGRect(x: padding, y: tokenSButton.frame.maxY, width: screenWidth - padding * 2, height: 1)
        tokenSUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(tokenSUnderLine)
        
        estimateValueInCurrency.font = FontConfigManager.shared.getLabelFont()
        estimateValueInCurrency.frame = CGRect(x: padding, y: tokenSUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(estimateValueInCurrency)
        
        maxButton.title = NSLocalizedString("Max", comment: "")
        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        maxButton.contentHorizontalAlignment = .right
        maxButton.frame = CGRect(x: screenWidth-80-padding, y: tokenSUnderLine.frame.maxY, width: 80, height: 40)
        scrollView.addSubview(maxButton)
        
        // Second row: exchange label
        
        exchangeImage.image = UIImage(named: "Trading")
        exchangeLabel.font = FontConfigManager.shared.getLabelFont()
        exchangeLabel.textAlignment = .center
        exchangeLabel.frame = CGRect(x: 0, y: estimateValueInCurrency.frame.maxY + padding*2, width: screenWidth, height: 40)
        scrollView.addSubview(exchangeLabel)
        
        // Thrid row: TokenB

        tokenBButton.setTitleColor(UIColor.black, for: .normal)
        tokenBButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        tokenBButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        tokenBButton.frame = CGRect(x: screenWidth-padding-tokenButtonWidth, y: exchangeLabel.frame.maxY + padding*2, width: tokenButtonWidth, height: 40)
        tokenBButton.addTarget(self, action: #selector(pressedSwitchTokenBButton), for: .touchUpInside)
        scrollView.addSubview(tokenBButton)
        
        amountBuyTextField.delegate = self
        amountBuyTextField.tag = 2
        amountBuyTextField.inputView = UIView()
        amountBuyTextField.font = FontConfigManager.shared.getLabelFont()
        
        amountBuyTextField.theme_tintColor = GlobalPicker.textColor
        amountBuyTextField.placeholder = NSLocalizedString("Enter the amount you get", comment: "")
        amountBuyTextField.contentMode = UIViewContentMode.bottom
        amountBuyTextField.frame = CGRect(x: padding, y: exchangeLabel.frame.maxY + padding*2, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountBuyTextField)
        
        totalUnderLine.frame = CGRect(x: padding, y: tokenBButton.frame.maxY, width: screenWidth - padding * 2, height: 1)
        totalUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(totalUnderLine)
        
        availableLabel.text = ""
        availableLabel.font = FontConfigManager.shared.getLabelFont()
        availableLabel.frame = CGRect(x: padding, y: totalUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(availableLabel)

        scrollView.contentSize = CGSize(width: screenWidth, height: availableLabel.frame.maxY + 30)
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tokenSButton.setTitle(TradeDataManager.shared.tokenS.symbol, for: .normal)
        tokenSButton.setRightImage(imageName: "Arrow-down-black", imagePaddingTop: 0, imagePaddingLeft: 10, titlePaddingRight: 0)
        tokenBButton.setTitle(TradeDataManager.shared.tokenB.symbol, for: .normal)
        tokenBButton.setRightImage(imageName: "Arrow-down-black", imagePaddingTop: 0, imagePaddingLeft: 10, titlePaddingRight: 0)
        updateTipLabel()
        updateInfoLabel()
    }
    
    func updateInfoLabel() {
        let tokens = TradeDataManager.shared.tokenS.symbol
        let tokenb = TradeDataManager.shared.tokenB.symbol
        let pair = TradeDataManager.shared.tradePair
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            exchangeLabel.isHidden = false
            exchangeLabel.text = "Exchange (1 \(tokens) ≈ \(market.balance) \(tokenb))"
            let width = (UIScreen.main.bounds.width - exchangeLabel.intrinsicContentSize.width) / 2
            exchangeImage.frame = CGRect(x: width - 25, y: 10, width: 20, height: 20)
            exchangeLabel.addSubview(exchangeImage)
        } else {
            exchangeLabel.isHidden = true
        }
    }
    
    func updateTipLabel(text: String? = nil, color: UIColor? = nil) {
        if let text = text, let color = color {
            estimateValueInCurrency.text = text
            estimateValueInCurrency.textColor = color
        } else {
            let tokens = TradeDataManager.shared.tokenS.symbol
            if let balance = CurrentAppWalletDataManager.shared.getBalance(of: tokens) {
                estimateValueInCurrency.text = NSLocalizedString("Available \(balance) \(tokens)", comment: "")
            } else {
                estimateValueInCurrency.text = NSLocalizedString("Available 0.0 \(tokens)", comment: "")
            }
            estimateValueInCurrency.textColor = .black
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        amountSellTextField.resignFirstResponder()
        amountBuyTextField.resignFirstResponder()
        hideNumericKeyboard()
    }
    
    @objc func pressQRCodeButton(_ sender: Any) {
        print("Selected Scan QR code")
        let viewController = ScanQRCodeViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressedSwitchTokenSButton(_ sender: Any) {
        print("pressedSwitchTokenSButton")
        let viewController = SwitchTradeTokenViewController()
        viewController.type = .tokenS
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressedSwitchTokenBButton(_ sender: Any) {
        print("pressedSwitchTokenBButton")
        let viewController = SwitchTradeTokenViewController()
        viewController.type = .tokenB
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedNextButton(_ sender: Any) {
        print("pressedNextButton")
        self.validateRational()
    }
    
    func pushController() {
        let viewController = TradeReviewViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        activeTextFieldTag = textField.tag
        showNumericKeyboard(textField: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    func getActiveTextField() -> UITextField? {
        if activeTextFieldTag == amountSellTextField.tag {
            return amountSellTextField
        } else if activeTextFieldTag == amountBuyTextField.tag {
            return amountBuyTextField
        } else {
            return nil
        }
    }
    
    func updateButton(isValid: Bool) {
        nextButton.isEnabled = isValid
    }
    
    func validateRational() {
        let pair = TradeDataManager.shared.tradePair
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            let value = Double(amountBuyTextField.text!)! / Double(amountSellTextField.text!)!
            // TODO: get from setting maybe
            if value < 0.8 * market.balance || value > 1.2 * market.balance {
                let title = NSLocalizedString("Your price is irrational. Do you want to continue trading with the price?", comment: "")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                    DispatchQueue.main.async {
                        self.pushController()
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.pushController()
            }
        } else {
            self.pushController()
        }
    }
    
    func validateAmountSell() -> Bool {
        var text: String
        let tokens = TradeDataManager.shared.tokenS.symbol
        if let amounts = amountSellTextField.text, let amountSell = Double(amounts) {
            if let balance = CurrentAppWalletDataManager.shared.getBalance(of: tokens) {
                text = NSLocalizedString("Available \(balance) \(tokens)", comment: "")
                if amountSell > balance {
                    updateTipLabel(text: text, color: .red)
                    return false
                } else {
                    if let price = PriceDataManager.shared.getPrice(of: tokens) {
                        let estimateValue: Double = amountSell * price
                        text = estimateValue.currency + "\t" + text
                    }
                    updateTipLabel(text: text, color: .black)
                    return true
                }
            } else {
                text = NSLocalizedString("Available 0.0 \(tokens)", comment: "")
                if amountSell == 0 {
                    text = 0.0.currency + text
                    updateTipLabel(text: text, color: .black)
                    return true
                } else {
                    updateTipLabel(text: text, color: .red)
                    return false
                }
            }
        } else {
            if let balance = CurrentAppWalletDataManager.shared.getBalance(of: tokens) {
                text = NSLocalizedString("Available \(balance) \(tokens)", comment: "")
            } else {
                text = NSLocalizedString("Available 0.0 \(tokens)", comment: "")
            }
            updateTipLabel(text: text, color: .black)
            return false
        }
    }
    
    func validateAmountBuy() -> Bool {
        if let amountb = amountBuyTextField.text, Double(amountb) != nil {
            availableLabel.isHidden = true
            return true
        } else {
            return false
        }
    }
    
    func validate() {
        var isValid = false
        if activeTextFieldTag == amountSellTextField.tag {
            _ = validateAmountSell()
        } else if activeTextFieldTag == amountBuyTextField.tag {
            _ = validateAmountBuy()
        }
        isValid = validateAmountSell() && validateAmountBuy()
        updateButton(isValid: isValid)
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShown {
            let width = self.view.frame.width
            let height = self.nextBackgroundView.frame.origin.y

            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            view.bringSubview(toFront: nextBackgroundView)
            view.bringSubview(toFront: nextButton)
            
            let destinateY = height - DefaultNumericKeyboard.height
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShown = true
                if finished {
                    if textField.tag == self.amountBuyTextField.tag {
                        let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                        self.scrollView.setContentOffset(bottomOffset, animated: true)
                    }
                }
            })
        } else {
            if textField.tag == amountBuyTextField.tag {
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShown {
            let width = self.view.frame.width
            let height = self.nextBackgroundView.frame.origin.y
            let destinateY = height
            self.scrollViewButtonLayoutConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShown = false
                if finished {
                    
                }
            })
        } else {
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
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
            activeTextField!.text = currentText + "."
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
        validate()
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
