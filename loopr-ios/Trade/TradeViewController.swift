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

class TradeViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol, StepSliderDelegate {
    
    // Header
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var tradingPairTokenSLabel: UILabel!
    @IBOutlet weak var tradingPairTokenBLabel: UILabel!
    @IBOutlet weak var swapButton: UIButton!
    
    @IBOutlet weak var tradingPairLabelOffsetLayoutConstraint: NSLayoutConstraint!
    var priceS: Double?
    @IBOutlet weak var tradingPairTokenSPriceLabel: UILabel!
    @IBOutlet weak var tradingPairTokenBPriceLabel: UILabel!
    
    // container
    @IBOutlet weak var containerView: UIView!
    
    // TokenS
    @IBOutlet weak var tokenSButton: UIButton!
    @IBOutlet weak var amountSellTextField: UITextField!
    @IBOutlet weak var estimateValueInCurrency: UILabel!
    @IBOutlet weak var sellTokenLabel: UILabel!
    
    // TokenB
    @IBOutlet weak var tokenBButton: UIButton!
    @IBOutlet weak var amountBuyTextField: UITextField!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var buyTokenLabel: UILabel!
    
    // Slider
    @IBOutlet weak var sliderView: UIView!
    
    // TTL Buttons
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    
    // Sell ratio
    @IBOutlet weak var sellRatioTipLabel: UILabel!
    @IBOutlet weak var sellRatioValueLabel: UILabel!
    @IBOutlet weak var sellRatioButton: UIButton!

    // Place button
    @IBOutlet weak var nextButton: UIButton!
    
    // Scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    // Numeric keyboard
    var isNumericKeyboardShown: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!

    var activeTextFieldTag = -1
    var stepSlider: StepSlider = StepSlider.getDefault()
    var isViewDidAppear: Bool = false
    
    // Expires
    var buttons: [UIButton] = []
    var intervalValue = 1
    var intervalUnit: Calendar.Component = .hour
    var distance: CGFloat = 0
    
    // Drag down to close a present view controller.
    var blurVisualEffectView = UIView()
    var dismissInteractor: MiniToLargeViewInteractive!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = ColorPicker.backgroundColor
        self.navigationItem.title = LocalizedString("P2P Trade", comment: "")
        setBackButton()
        
        headerButton.clipsToBounds = true
        headerButton.layer.cornerRadius = 6
        headerButton.theme_setBackgroundImage(ColorPicker.button, forState: .normal)
        headerButton.theme_setBackgroundImage(ColorPicker.buttonSelected, forState: .highlighted)
        headerButton.isUserInteractionEnabled = false
        
        swapButton.addTarget(self, action: #selector(pressedHeaderButton), for: .touchUpInside)

        tradingPairTokenSLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        tradingPairTokenSLabel.theme_textColor = GlobalPicker.textColor
        
        tradingPairTokenSPriceLabel.font = FontConfigManager.shared.getRegularFont(size: 11)
        tradingPairTokenSPriceLabel.theme_textColor = GlobalPicker.textColor
        tradingPairTokenSPriceLabel.text = "1LRC ≈ 6.1948 ARP"
        
        tradingPairTokenBLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        tradingPairTokenBLabel.theme_textColor = GlobalPicker.textColor

        tradingPairTokenBPriceLabel.font = FontConfigManager.shared.getRegularFont(size: 11)
        tradingPairTokenBPriceLabel.theme_textColor = GlobalPicker.textColor
        tradingPairTokenBPriceLabel.text = "1ARP ≈ 0.1316 LRC"

        tradingPairTokenSLabel.isUserInteractionEnabled = true
        tradingPairTokenSLabel.addGestureRecognizer(setPrefillPriceGestureRecognizer())
        tradingPairTokenSPriceLabel.isUserInteractionEnabled = true
        tradingPairTokenSPriceLabel.addGestureRecognizer(setPrefillPriceGestureRecognizer())
        tradingPairTokenBLabel.isUserInteractionEnabled = true
        tradingPairTokenBLabel.addGestureRecognizer(setPrefillPriceGestureRecognizer())
        tradingPairTokenBPriceLabel.isUserInteractionEnabled = true
        tradingPairTokenBPriceLabel.addGestureRecognizer(setPrefillPriceGestureRecognizer())
        
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor

        // First row: TokenS
        amountSellTextField.delegate = self
        amountSellTextField.tag = 0
        amountSellTextField.inputView = UIView()
        amountSellTextField.font = FontConfigManager.shared.getDigitalFont()
        amountSellTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountSellTextField.placeholder = LocalizedString("Amount to sell", comment: "")
        amountSellTextField.setLeftPaddingPoints(8)
        amountSellTextField.setRightPaddingPoints(72)
        amountSellTextField.contentMode = UIViewContentMode.bottom
        
        estimateValueInCurrency.font = FontConfigManager.shared.getCharactorFont(size: 12)
        estimateValueInCurrency.theme_textColor = GlobalPicker.textLightColor
        
        tokenSButton.addTarget(self, action: #selector(pressedTokenSButton), for: .touchUpInside)
        let sellTokenLabelTap = UITapGestureRecognizer(target: self, action: #selector(pressedTokenSButton))
        sellTokenLabelTap.numberOfTapsRequired = 1
        sellTokenLabel.addGestureRecognizer(sellTokenLabelTap)
        sellTokenLabel.isUserInteractionEnabled = true
        
        // Second row: TokenB
        amountBuyTextField.delegate = self
        amountBuyTextField.tag = 1
        amountBuyTextField.inputView = UIView()
        amountBuyTextField.font = FontConfigManager.shared.getDigitalFont()
        amountBuyTextField.theme_tintColor = GlobalPicker.contrastTextColor
        amountBuyTextField.placeholder = LocalizedString("Amount to buy", comment: "")
        amountBuyTextField.setLeftPaddingPoints(8)
        amountBuyTextField.setRightPaddingPoints(72)
        amountBuyTextField.contentMode = UIViewContentMode.bottom
        
        availableLabel.font = FontConfigManager.shared.getCharactorFont(size: 12)
        availableLabel.theme_textColor = GlobalPicker.textLightColor
        
        tokenBButton.addTarget(self, action: #selector(pressedTokenBButton), for: .touchUpInside)
        let buyTokenLabelTap = UITapGestureRecognizer(target: self, action: #selector(pressedTokenBButton))
        buyTokenLabelTap.numberOfTapsRequired = 1
        buyTokenLabel.addGestureRecognizer(buyTokenLabelTap)
        buyTokenLabel.isUserInteractionEnabled = true

        // Slider
        let screenWidth = UIScreen.main.bounds.width
        stepSlider.frame = CGRect(x: 15, y: sliderView.frame.minY, width: screenWidth-60, height: 20)
        stepSlider.delegate = self
        stepSlider.maxCount = 4
        stepSlider.setIndex(0, animated: false)
        stepSlider.labels = ["0%", "25%", "50%", "75%", "100%"]
        containerView.addSubview(stepSlider)

        // Buttons
        hourButton.round(corners: [.topLeft, .bottomLeft], radius: 8)
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
        hourButton.title = LocalizedString("1 Hour", comment: "")
        dayButton.title = LocalizedString("1 Day", comment: "")
        monthButton.title = LocalizedString("1 Month", comment: "")
        customButton.title = LocalizedString("Custom", comment: "")
        buttons = [hourButton, dayButton, monthButton, customButton]
        buttons.forEach {
            $0.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
            $0.theme_setTitleColor(GlobalPicker.textColor, forState: .selected)
            $0.theme_setTitleColor(GlobalPicker.textLightColor, forState: .normal)
            $0.setBackgroundColor(UIColor.dark3, for: .normal)
        }
        hourButton.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 13)
        
        // Sell ratio
        sellRatioTipLabel.font = FontConfigManager.shared.getCharactorFont(size: 14)
        sellRatioTipLabel.theme_textColor = GlobalPicker.textLightColor
        sellRatioTipLabel.text = LocalizedString("Minimal Fill", comment: "")
        
        sellRatioValueLabel.font = FontConfigManager.shared.getDigitalFont(size: 14)
        sellRatioValueLabel.theme_textColor = GlobalPicker.textColor
        sellRatioValueLabel.text = "100%"

        // Place button
        nextButton.title = LocalizedString("Next", comment: "")
        nextButton.setupSecondary(height: 44)

        // Scroll view
        scrollView.delegate = self
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.delaysContentTouches = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: containerView.frame.maxY)
        
        self.distance = 0
        self.scrollViewButtonLayoutConstraint.constant = self.distance
        
        TradeDataManager.shared.sellRatio = 1
        
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
        update()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // TODO: current solution is to set the initial value here.
        if !isViewDidAppear {
            stepSlider.setPercentageValue(0.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // stepSlider.setPercentageValue(0.1)
        isViewDidAppear = true
        customButton.round(corners: [.topRight, .bottomRight], radius: 8)
    }
    
    @objc func pressedHeaderButton() {
        print("switch tokens in TradeDataManager")
        
        TradeDataManager.shared.swapTokenSAndTokenB()
        // Swap text field values
        let tmp = amountSellTextField.text
        amountSellTextField.text = amountBuyTextField.text
        amountBuyTextField.text = tmp
        update()
    }

    func update(text: String? = nil, color: UIColor? = nil) {
        var message: String = ""
        let tokens = TradeDataManager.shared.tokenS.symbol
        let tokenb = TradeDataManager.shared.tokenB.symbol
        
        tradingPairTokenSLabel.text = tokens
        tradingPairTokenBLabel.text = tokenb
        
        // Update the price
        if let tokenSPrice = PriceDataManager.shared.getPrice(of: tokens), let tokenBPrice = PriceDataManager.shared.getPrice(of: tokenb) {
            if tokenSPrice > 0 && tokenBPrice > 0 {
                self.priceS = tokenSPrice/tokenBPrice
                let priceSString: String
                if self.priceS! > 1.0 {
                    priceSString = self.priceS!.withCommas(1)
                } else {
                    priceSString = self.priceS!.withCommas(6)
                }
                tradingPairTokenSPriceLabel.attributedText = "1 \(tokens) ≈ \(priceSString) \(tokenb)".higlighted(words: [priceSString], attributes: [NSAttributedStringKey.foregroundColor: UIColor.theme])
                
                let priceB = 1/self.priceS!
                let priceBString: String
                if priceB > 1.0 {
                    priceBString = priceB.withCommas(1)
                } else {
                    priceBString = priceB.withCommas(6)
                }
                tradingPairTokenBPriceLabel.attributedText = "1 \(tokenb) ≈ \(priceBString) \(tokens)".higlighted(words: [priceBString], attributes: [NSAttributedStringKey.foregroundColor: UIColor.theme])
            } else {
                self.priceS = nil
            }
        } else {
            self.priceS = nil
        }
        
        if self.priceS == nil {
            tradingPairTokenSPriceLabel.isHidden = true
            tradingPairTokenBPriceLabel.isHidden = true
            tradingPairLabelOffsetLayoutConstraint.constant = 0
        } else {
            tradingPairTokenSPriceLabel.isHidden = false
            tradingPairTokenBPriceLabel.isHidden = false
            tradingPairLabelOffsetLayoutConstraint.constant = 9
        }
        
        let title = LocalizedString("Available Balance", comment: "")
        
        if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: tokens) {
            message = "\(title) \(asset.display) \(tokens)"
        } else {
            message = "\(title) 0.0 \(tokens)"
        }
        buyTokenLabel.text = tokenb
        sellTokenLabel.text = tokens
        estimateValueInCurrency.text = text ?? message
        estimateValueInCurrency.textColor = color ?? .text2
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
    
    @objc func pressedPrefillPrice() {
        print("pressedPrefillPrice")
        let isSellValid = validateAmountSell()
        if isSellValid && self.priceS != nil {
            if self.priceS! > 0, let amounts = amountSellTextField.text, let amountSell = Double(amounts) {
                amountBuyTextField.text = (amountSell * self.priceS!).withCommas(10).trailingZero()
            }
        }
    }
    
    func setPrefillPriceGestureRecognizer() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressedPrefillPrice))
        tap.numberOfTapsRequired = 1
        return tap
    }
    
    @objc func pressedTokenSButton() {
        print("pressedSwitchTokenSButton")
        let viewController = SwitchTradeTokenViewController()
        viewController.type = .tokenS
        viewController.needUpdateClosure = {
            self.amountSellTextField.text = ""
            self.amountBuyTextField.text = ""
        }
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func pressedTokenBButton() {
        print("pressedSwitchTokenBButton")
        let viewController = SwitchTradeTokenViewController()
        viewController.type = .tokenB
        viewController.needUpdateClosure = {
            self.amountSellTextField.text = ""
            self.amountBuyTextField.text = ""
        }
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func pressedExpiresButton(_ sender: UIButton) {
        let dict: [Int: Calendar.Component] = [0: .hour, 1: .day, 2: .month]
        for (index, button) in buttons.enumerated() {
            button.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 13)
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
        sender.titleLabel?.font = FontConfigManager.shared.getMediumFont(size: 13)
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
    
    @IBAction func pressedRatioButton(_ sender: UIButton) {
        let parentView = self.parent!.view!
        parentView.alpha = 0.25
        let vc = TradeRatioViewController()
        vc.dismissClosure = {
            parentView.alpha = 1
            TradeDataManager.shared.sellRatio = vc.sellRatio
            self.sellRatioValueLabel.text = "\(vc.sellRatio * 100)" + NumberFormatter().percentSymbol
        }
        vc.parentNavController = self.navigationController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.present(vc, animated: true, completion: nil)
    }
    
    func present() {
        self.hideNumericKeyboard()
        let parentView = self.parent!.view!
        parentView.alpha = 0.25
        let vc = TimeToLiveViewController()
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
        
        var order = OriginalOrder(delegate: delegate, address: address, side: "sell", tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: 0, buyNoMoreThanAmountB: buyNoMoreThanAmountB, orderType: .p2pOrder, p2pType: .maker, market: market)
        PlaceOrderDataManager.shared.completeOrder(&order)
        return order
    }
    
    func preserveMaker(order: OriginalOrder) {
        let defaults = UserDefaults.standard
        let ratio = TradeDataManager.shared.sellRatio
        defaults.set("\(order.authPrivateKey)-\(ratio)", forKey: order.hash)
    }
    
    func pushController() {
        if let order = constructMaker() {
            preserveMaker(order: order)
            TradeDataManager.shared.isTaker = false
            let viewController = TradeConfirmationViewController()
            viewController.order = order
            
            viewController.transitioningDelegate = self
            viewController.modalPresentationStyle = .overFullScreen
            viewController.dismissClosure = {
                UIView.animate(withDuration: 0.2, animations: {
                    self.blurVisualEffectView.alpha = 0.0
                }, completion: {(_) in
                    self.blurVisualEffectView.removeFromSuperview()
                })
            }
            
            dismissInteractor = MiniToLargeViewInteractive()
            dismissInteractor.percentThreshold = 0.2
            dismissInteractor.dismissClosure = {
                
            }
            
            self.present(viewController, animated: true) {
                self.dismissInteractor.attachToViewController(viewController: viewController, withView: viewController.containerView, presentViewController: nil, backgroundView: self.blurVisualEffectView)
            }
            
            self.navigationController?.view.addSubview(self.blurVisualEffectView)
            UIView.animate(withDuration: 0.3, animations: {
                self.blurVisualEffectView.alpha = 1.0
            }, completion: {(_) in
                
            })
            
            viewController.parentNavController = self.navigationController
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
                availableLabel.textColor = .text2
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
            
            // TODO: udpate the price?
            // pressedPrefillPrice()
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
            }, completion: { _ in
                self.isNumericKeyboardShown = true
            })
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
        estimateValueInCurrency.textColor = .text2
        activeTextFieldTag = amountSellTextField.tag
        _ = validate()
    }
}

extension TradeViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.initialY = 0
        animator.transitionType = .Dismiss
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }
    
}
