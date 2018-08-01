//
//  TradeBuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import StepSlider

class TradeViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol, StepSliderDelegate {
    
    // container
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var totalMaskView: UIView!
    
    // TokenS
    @IBOutlet weak var tokenSButton: UIButton!
    @IBOutlet weak var amountSellTextField: UITextField!
    @IBOutlet weak var estimateValueInCurrency: UILabel!
    @IBOutlet weak var sellTipLabel: UILabel!
    @IBOutlet weak var sellTokenLabel: UILabel!
    
    // TokenB
    @IBOutlet weak var tokenBButton: UIButton!
    @IBOutlet weak var amountBuyTextField: UITextField!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var buyTipLabel: UILabel!
    @IBOutlet weak var buyTokenLabel: UILabel!
    
    // Slider
    @IBOutlet weak var sliderView: UIView!
    
    // TTL Buttons
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    
    // Container
    @IBOutlet weak var canTipLabel: UILabel!
    @IBOutlet weak var canInfoLabel: UILabel!

    // Place button
    @IBOutlet weak var nextButton: UIButton!
    
    // Scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    // Numeric keyboard
    var isNumericKeyboardShown: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!

    var activeTextFieldTag = -1
    var stepSlider: StepSlider = StepSlider()
    
    // Expires
    var buttons: [UIButton] = []
    var intervalValue = 1
    var intervalUnit: Calendar.Component = .hour
    var distance: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        setBackButton()

        // First row: TokenS
        amountSellTextField.delegate = self
        amountSellTextField.tag = 0
        amountSellTextField.inputView = UIView()
        amountSellTextField.font = FontConfigManager.shared.getDigitalFont()
        amountSellTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountSellTextField.placeholder = LocalizedString("Enter the amount you have", comment: "")
        amountSellTextField.setLeftPaddingPoints(40)
        amountSellTextField.setRightPaddingPoints(72)
        amountSellTextField.contentMode = UIViewContentMode.bottom
        estimateValueInCurrency.setSubTitleCharFont()
        sellTipLabel.text = LocalizedString("Sell", comment: "")
        
        // Second row: TokenB
        amountBuyTextField.delegate = self
        amountBuyTextField.tag = 1
        amountBuyTextField.inputView = UIView()
        amountBuyTextField.font = FontConfigManager.shared.getDigitalFont()
        amountBuyTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountBuyTextField.placeholder = LocalizedString("Enter the amount you get", comment: "")
        amountBuyTextField.setLeftPaddingPoints(40)
        amountBuyTextField.setRightPaddingPoints(72)
        amountBuyTextField.contentMode = UIViewContentMode.bottom
        availableLabel.setSubTitleCharFont()
        buyTipLabel.text = LocalizedString("Buy", comment: "")
        
        // Slider
        stepSlider.frame = sliderView.frame
        stepSlider.delegate = self
        stepSlider.maxCount = 4
        stepSlider.labelFont = FontConfigManager.shared.getRegularFont(size: 12)
        stepSlider.labelColor = UIColor.init(white: 0.6, alpha: 1)
        stepSlider.setIndex(0, animated: false)
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
        containerView.addSubview(stepSlider)

        // Buttons
        hourButton.round(corners: [.topLeft, .bottomLeft], radius: 8)
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
        hourButton.title = LocalizedString("1 Hour", comment: "")
        dayButton.title = LocalizedString("1 Day", comment: "")
        monthButton.title = LocalizedString("1 Month", comment: "")
        customButton.title = LocalizedString("Custom", comment: "")
        buttons = [hourButton, dayButton, monthButton, customButton]
        hourButton.titleLabel?.font = FontConfigManager.shared.getBoldFont()
        buttons.forEach {
            $0.titleLabel?.font = FontConfigManager.shared.getDigitalFont()
            $0.theme_setTitleColor(GlobalPicker.textColor, forState: .selected)
            $0.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
        }
        
        // Total
        canTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 15)
        canTipLabel.theme_textColor = GlobalPicker.textLightColor
        canTipLabel.text = LocalizedString("Can Buy", comment: "")
        canInfoLabel.setTitleCharFont()

        // Place button
        nextButton.title = LocalizedString("Next", comment: "")
        nextButton.setupSecondary(height: 40)

        // Scroll view
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: containerView.frame.maxY)
        scrollView.delaysContentTouches = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.distance = UIScreen.main.bounds.height - containerView.frame.maxY
        self.scrollViewButtonLayoutConstraint.constant = self.distance
        update()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // TODO: current solution is to set the initial value here.
        stepSlider.setPercentageValue(0.1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stepSlider.setPercentageValue(0.1)
    }

    func update(text: String? = nil, color: UIColor? = nil) {
        var message: String = ""
        let tokens = TradeDataManager.shared.tokenS.symbol
        let tokenb = TradeDataManager.shared.tokenB.symbol
        let title = LocalizedString("Available Balance", comment: "")
        
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokens) {
            message = "\(title) \(asset.display) \(tokens)"
            if let prices = PriceDataManager.shared.getPrice(of: tokens),
               let priceb = PriceDataManager.shared.getPrice(of: tokenb) {
                let ratio = prices / priceb * asset.balance
                canInfoLabel.text = "\(ratio.withCommas()) \(tokenb)"
            } else {
                canInfoLabel.text = "-- \(tokenb)"
            }
        } else {
            message = "\(title) 0.0 \(tokens)"
        }
        buyTokenLabel.text = tokenb
        sellTokenLabel.text = tokens
        estimateValueInCurrency.text = text ?? message
        estimateValueInCurrency.textColor = color ?? .text1
        if color == .fail {
            estimateValueInCurrency.shake()
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        amountSellTextField.resignFirstResponder()
        amountBuyTextField.resignFirstResponder()
        hideNumericKeyboard()
    }
    
    @IBAction func pressedTokenSButton(_ sender: UIButton) {
        print("pressedSwitchTokenSButton")
        let viewController = SwitchTradeTokenViewController()
        viewController.type = .tokenS
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedTokenBButton(_ sender: UIButton) {
        print("pressedSwitchTokenBButton")
        let viewController = SwitchTradeTokenViewController()
        viewController.type = .tokenB
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedExpiresButton(_ sender: UIButton) {
        let dict: [Int: Calendar.Component] = [0: .hour, 1: .day, 2: .month]
        for (index, button) in buttons.enumerated() {
            button.titleLabel?.font = FontConfigManager.shared.getDigitalFont()
            button.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
            if button == sender {
                if index < 3 {
                    self.intervalValue = 1
                    self.intervalUnit = dict[index]!
                } else if index == 3 {
                    self.present()
                }
            }
            button.isSelected = false
        }
        sender.isSelected = true
        sender.titleLabel?.font = FontConfigManager.shared.getBoldFont()
    }
    
    @IBAction func pressedNextButton(_ sender: Any) {
        print("pressedNextButton")
        hideNumericKeyboard()
        amountSellTextField.resignFirstResponder()
        amountBuyTextField.resignFirstResponder()
        
        let isBuyValid = validateAmountBuy()
        let isSellValid = validateAmountSell()
        if isSellValid && isBuyValid {
            self.pushController()
        }
        if !isSellValid && estimateValueInCurrency.textColor != .fail {
            update(text: LocalizedString("Please input a valid amount", comment: ""), color: .fail)
        }
        if !isBuyValid {
            availableLabel.isHidden = false
            availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            availableLabel.textColor = .fail
            availableLabel.shake()
        }
    }
    
    func present() {
        self.hideNumericKeyboard()
        let parentView = self.parent!.view!
        parentView.alpha = 0.25
        let vc = TTLViewController()
        vc.dismissClosure = {
            parentView.alpha = 1
            self.intervalUnit = vc.intervalUnit
            self.intervalValue = vc.intervalValue
        }
        vc.parentNavController = self.navigationController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.present(vc, animated: true, completion: nil)
    }
    
    func constructMaker() -> OriginalOrder? {
        var buyNoMoreThanAmountB: Bool
        var amountBuy, amountSell: Double
        var tokenSell, tokenBuy, market: String
        
        tokenBuy = TradeDataManager.shared.tokenB.symbol
        tokenSell = TradeDataManager.shared.tokenS.symbol
        market = "\(tokenSell)/\(tokenBuy)"
        amountBuy = Double(amountBuyTextField.text!)!
        amountSell = Double(amountSellTextField.text!)!
        
        buyNoMoreThanAmountB = false
        let delegate = RelayAPIConfiguration.delegateAddress
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        
        let since = Int64(Date().timeIntervalSince1970)
        let until = Int64(Calendar.current.date(byAdding: intervalUnit, value: intervalValue, to: Date())!.timeIntervalSince1970)
        
        var order = OriginalOrder(delegate: delegate, address: address, side: "sell", tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: 0, buyNoMoreThanAmountB: buyNoMoreThanAmountB, orderType: .p2pOrder, market: market)
        PlaceOrderDataManager.shared.completeOrder(&order)
        return order
    }
    
    func preserveMaker(order: OriginalOrder) {
        let defaults = UserDefaults.standard
        let orderData = [order.hash: order.authPrivateKey]
        defaults.set(orderData, forKey: UserDefaultsKeys.p2pOrder.rawValue)
    }
    
    func pushController() {
        if let order = constructMaker() {
//            preserveMaker(order: order)
//            TradeDataManager.shared.isTaker = false
//            self.totalMaskView.alpha = 0.75
//            let vc = TradeConfirmationViewController()
//            vc.order = order
//            vc.dismissClosure = {
//                self.totalMaskView.alpha = 0
//            }
//            vc.parentNavController = self.navigationController
//            self.present(vc, animated: true, completion: nil)
            
            let vc = TradeReviewViewController()
            vc.order = order
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func validateAmountSell() -> Bool {
        var text: String
        let tokens = TradeDataManager.shared.tokenS.symbol
        let title = LocalizedString("Available Balance", comment: "")
        if let amounts = amountSellTextField.text, let amountSell = Double(amounts) {
            if let balance = CurrentAppWalletDataManager.shared.getBalance(of: tokens) {
                if amountSell > balance {
                    update(text: nil, color: .fail)
                    return false
                } else {
                    if let price = PriceDataManager.shared.getPrice(of: tokens) {
                        let estimateValue: Double = amountSell * price
                        text = "≈\(estimateValue.currency)"
                        update(text: text)
                    }
                    return true
                }
            } else {
                if amountSell == 0 {
                    text = 0.0.currency
                    update(text: text)
                    return true
                } else {
                    text = "\(title) 0.0 \(tokens)"
                    update(text: text, color: .fail)
                    return false
                }
            }
        } else {
            update()
            return false
        }
    }
    
    func validateAmountBuy() -> Bool {
        availableLabel.isHidden = true
        if let amountb = amountBuyTextField.text, let amountBuy = Double(amountb) {
            let tokenb = TradeDataManager.shared.tokenB.symbol
            if let price = PriceDataManager.shared.getPrice(of: tokenb) {
                let estimateValue: Double = amountBuy * price
                availableLabel.isHidden = false
                availableLabel.textColor = .text1
                availableLabel.text = "≈\(estimateValue.currency)"
            }
            return true
        } else {
            return false
        }
    }
    
    func validate() -> Bool {
        var isValid = false
        if activeTextFieldTag == amountSellTextField.tag {
            isValid = validateAmountSell()
        } else if activeTextFieldTag == amountBuyTextField.tag {
            isValid = validateAmountBuy()
        }
        return isValid
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        activeTextFieldTag = textField.tag
        showNumericKeyboard(textField: textField)
        _ = validate()
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
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShown {
            let width = self.view.frame.width
            let height = self.view.frame.height

            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            
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
            let height = self.view.frame.height
            let destinateY = height
            self.scrollViewButtonLayoutConstraint.constant = self.distance
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
    
    func stepSliderValueChanged(_ value: Double) {
        var message: String = ""
        let tokens = TradeDataManager.shared.tokenS.symbol
        let length = Asset.getLength(of: tokens) ?? 4
        let title = LocalizedString("Available Balance", comment: "")
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokens) {
            message = "\(title) \(asset.display) \(tokens)"
            amountSellTextField.text = (asset.balance * value).withCommas(length)
        } else {
            message = "\(title) 0.0 \(tokens)"
            amountSellTextField.text = "0.0"
        }
        estimateValueInCurrency.text = message
        estimateValueInCurrency.textColor = .text1
        activeTextFieldTag = amountSellTextField.tag
        _ = validate()
    }
}
