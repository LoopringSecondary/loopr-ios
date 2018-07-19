//
//  BuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import NotificationBannerSwift
import SVProgressHUD

class BuyViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol, PriceStackViewDelegate, AmountStackViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var placeOrderBackgroundView: UIView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    // config
    var type: TradeType
    var expire: OrderExpire = .oneHour
    var intervalUnit: Calendar.Component = .hour
    var intervalValue = 1

    // Price
    var tokenALabel: UILabel = UILabel()
    var priceTextField: FloatLabelTextField!
    var tokenAUnderLine: UIView = UIView()
    var estimateValueInCurrencyLabel: UILabel = UILabel()
    var priceStackView: PriceStackView!

    // Amout
    var tokenBLabel: UILabel = UILabel()
    var amountTextField: FloatLabelTextField!
    var amountUnderLine: UIView = UIView()
    var tipLabel: UILabel = UILabel()
    var amountStackView: AmountStackView!

    // Total
    var tokenBTotalLabel: UILabel = UILabel()
    var totalTextField: UITextField = UITextField()
    var totalUnderLine: UIView = UIView()
    var availableLabel: UILabel = UILabel()
    
    // Expire
    var expireLabel: UILabel = UILabel()
    var stackView: UIStackView   = UIStackView()
    var oneHourButton: CustomUIButtonForUIToolbar = CustomUIButtonForUIToolbar()
    var oneDayButton: CustomUIButtonForUIToolbar = CustomUIButtonForUIToolbar()
    var oneWeekButton: CustomUIButtonForUIToolbar = CustomUIButtonForUIToolbar()
    var oneMonthButton: CustomUIButtonForUIToolbar = CustomUIButtonForUIToolbar()

    // Numeric keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    var customerValue: String = ""
    var percentage: Double?
    var activeTextFieldTag = -1
    
    convenience init(type: TradeType) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        type = .buy
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        scrollViewButtonLayoutConstraint.constant = 0

        placeOrderButton.title = LocalizedString("Place Order", comment: "")
        placeOrderButton.setupSecondary()
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 50
        let padding: CGFloat = 15
        
        // First row: price
        setupLabels()
        tokenALabel.text = PlaceOrderDataManager.shared.tokenB.symbol
        tokenALabel.font = FontConfigManager.shared.getDigitalFont()
        tokenALabel.textAlignment = .right
        tokenALabel.frame = CGRect(x: screenWidth-80-padding, y: originY, width: 80, height: 40)
        scrollView.addSubview(tokenALabel)
        
        priceTextField = FloatLabelTextField(frame: CGRect(x: padding, y: tokenALabel.frame.minY, width: screenWidth-padding*2-80, height: 40))
        priceTextField.delegate = self
        priceTextField.tag = 0
        priceTextField.inputView = UIView()
        priceTextField.font = FontConfigManager.shared.getDigitalFont()
        priceTextField.theme_tintColor = GlobalPicker.textColor
        priceTextField.placeholder = LocalizedString("Market Price", comment: "") + " " + PlaceOrderDataManager.shared.market.balance.description
        priceTextField.contentMode = UIViewContentMode.bottom
        scrollView.addSubview(priceTextField)

        tokenAUnderLine.frame = CGRect(x: padding, y: tokenALabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        tokenAUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(tokenAUnderLine)

        let zeroValue: Double = 0.0
        estimateValueInCurrencyLabel.text = "≈ \(zeroValue.currency)"
        estimateValueInCurrencyLabel.font = FontConfigManager.shared.getDigitalFont()
        estimateValueInCurrencyLabel.frame = CGRect(x: padding, y: tokenAUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(estimateValueInCurrencyLabel)
        
        priceStackView = PriceStackView(frame: CGRect(x: screenWidth-195-padding, y: tokenAUnderLine.frame.maxY, width: 195, height: 40))
        priceStackView.delegate = self
        scrollView.addSubview(priceStackView)
        
        // Second row: amount
        tokenBLabel.text = PlaceOrderDataManager.shared.tokenA.symbol
        tokenBLabel.font = FontConfigManager.shared.getDigitalFont()
        tokenBLabel.textAlignment = .right
        tokenBLabel.frame = CGRect(x: screenWidth-80-padding, y: estimateValueInCurrencyLabel.frame.maxY + 30, width: 80, height: 40)
        scrollView.addSubview(tokenBLabel)
        
        amountTextField = FloatLabelTextField(frame: CGRect(x: padding, y: estimateValueInCurrencyLabel.frame.maxY + 30, width: screenWidth-padding*2-80, height: 40))
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getDigitalFont()
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.placeholder = LocalizedString("Please input a valid amount", comment: "")
        amountTextField.contentMode = UIViewContentMode.bottom
        scrollView.addSubview(amountTextField)
        
        amountUnderLine.frame = CGRect(x: padding, y: tokenBLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderLine)
        
        tipLabel.font = FontConfigManager.shared.getDigitalFont()
        tipLabel.frame = CGRect(x: padding, y: amountUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(tipLabel)
        // tipLabel.isHidden = true
        
        if self.type == .sell {
            amountStackView = AmountStackView(frame: CGRect(x: screenWidth-100-padding, y: amountUnderLine.frame.maxY, width: 100, height: 40))
            amountStackView.delegate = self
            scrollView.addSubview(amountStackView)
        }

        // Thrid row: total
        tokenBTotalLabel.text = PlaceOrderDataManager.shared.tokenB.symbol
        tokenBTotalLabel.font = FontConfigManager.shared.getDigitalFont()
        tokenBTotalLabel.textAlignment = .right
        tokenBTotalLabel.frame = CGRect(x: screenWidth-80-padding, y: tipLabel.frame.maxY + 30, width: 80, height: 40)
        scrollView.addSubview(tokenBTotalLabel)
        
        totalTextField.delegate = self
        totalTextField.tag = 2
        totalTextField.inputView = UIView()
        totalTextField.font = FontConfigManager.shared.getDigitalFont()
        totalTextField.theme_tintColor = GlobalPicker.textColor
        totalTextField.placeholder = LocalizedString("Total", comment: "")
        totalTextField.contentMode = UIViewContentMode.bottom
        totalTextField.frame = CGRect(x: padding, y: tipLabel.frame.maxY + 30, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(totalTextField)

        // Disable user input in totalTextField
        totalTextField.isEnabled = false

        totalUnderLine.frame = CGRect(x: padding, y: tokenBTotalLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        totalUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(totalUnderLine)

        availableLabel.font = FontConfigManager.shared.getDigitalFont()
        availableLabel.frame = CGRect(x: padding, y: totalUnderLine.frame.maxY, width: screenWidth-padding*2, height: 40)
        scrollView.addSubview(availableLabel)
        
        // Fourth Row
        expireLabel.text = LocalizedString("Order Expires in", comment: "")
        expireLabel.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        expireLabel.textAlignment = .left
        expireLabel.frame = CGRect(x: padding, y: availableLabel.frame.maxY + 30, width: 300, height: 40)
        scrollView.addSubview(expireLabel)

        stackView.axis  = UILayoutConstraintAxis.horizontal
        stackView.distribution  = UIStackViewDistribution.fillEqually
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing   = 20.0
        
        oneHourButton.setTitle(OrderExpire.oneHour.description, for: .normal)
        oneHourButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneHourButton.addTarget(self, action: #selector(self.pressedOneHourButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneHourButton)
        
        oneDayButton.setTitle(OrderExpire.oneDay.description, for: .normal)
        oneDayButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneDayButton.addTarget(self, action: #selector(self.pressedOneDayButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneDayButton)

        oneWeekButton.setTitle(OrderExpire.oneWeek.description, for: .normal)
        oneWeekButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneWeekButton.addTarget(self, action: #selector(self.pressedOneWeekButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneWeekButton)

        oneMonthButton.setTitle(OrderExpire.oneMonth.description, for: .normal)
        oneMonthButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneMonthButton.addTarget(self, action: #selector(self.pressedOneMonthButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneMonthButton)

        // TODO: how to get the initial value
        oneHourButton.selected()
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()

        stackView.frame = CGRect(x: 20.0, y: expireLabel.frame.maxY, width: screenWidth - 2 * 20.0, height: 29)
        scrollView.addSubview(stackView)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: stackView.frame.maxY + 30)

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLabels() {
        if let balance = getBalance() {
            let title = LocalizedString("Available Balance", comment: "")
            if type == .buy {
                availableLabel.isHidden = false
                availableLabel.textColor = .black
                availableLabel.text = "\(title) \(balance.withCommas()) \(PlaceOrderDataManager.shared.tokenB.symbol)"
            } else {
                tipLabel.isHidden = false
                tipLabel.textColor = .black
                tipLabel.text = "\(title) \(balance.withCommas()) \(PlaceOrderDataManager.shared.tokenA.symbol)"
            }
        }
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        print("Slider value changed \(sender.value)")
    }

    // To avoid gesture conflicts in swiping to back and UISlider
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: UISlider.self) {
            return false
        }
        return true
    }

    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        priceTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        totalTextField.resignFirstResponder()
        hideNumericKeyboard()
    }

    @objc func pressedOneHourButton(_ button: UIButton) {
        print("pressOneHourButton")
        self.expire = .oneHour
        self.intervalUnit = .hour
        oneHourButton.selected()
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
    }
    
    @objc func pressedOneDayButton(_ button: UIButton) {
        print("pressedOneDayButton")
        self.expire = .oneDay
        self.intervalUnit = .day
        oneHourButton.unselected()
        oneDayButton.selected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
    }
    
    @objc func pressedOneWeekButton(_ button: UIButton) {
        print("pressedOneWeekButton")
        self.expire = .oneWeek
        self.intervalUnit = .day
        self.intervalValue = 7
        oneHourButton.unselected()
        oneDayButton.unselected()
        oneWeekButton.selected()
        oneMonthButton.unselected()
    }
    
    @objc func pressedOneMonthButton(_ button: UIButton) {
        print("pressedOneMonthButton")
        self.expire = .oneMonth
        self.intervalUnit = .month
        oneHourButton.unselected()
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.selected()
    }
    
    func getBalance() -> Double? {
        if type == .buy {
            if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: PlaceOrderDataManager.shared.tokenB.symbol) {
                return asset.balance
            }
        } else if type == .sell {
            if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: PlaceOrderDataManager.shared.tokenA.symbol) {
                return asset.balance
            }
        }
        return nil
    }
    
    func constructOrder() -> OriginalOrder? {
        var buyNoMoreThanAmountB: Bool
        var side, tokenSell, tokenBuy: String
        var amountBuy, amountSell, lrcFee: Double
        if self.type == .buy {
            side = "buy"
            tokenBuy = PlaceOrderDataManager.shared.tokenA.symbol
            tokenSell = PlaceOrderDataManager.shared.tokenB.symbol
            buyNoMoreThanAmountB = true
            amountBuy = Double(amountTextField.text!)!
            amountSell = Double(totalTextField.text!)!
        } else {
            side = "sell"
            tokenBuy = PlaceOrderDataManager.shared.tokenB.symbol
            tokenSell = PlaceOrderDataManager.shared.tokenA.symbol
            buyNoMoreThanAmountB = false
            amountBuy = Double(totalTextField.text!)!
            amountSell = Double(amountTextField.text!)!
        }
        lrcFee = getLrcFee(amountSell, tokenSell)
        let delegate = RelayAPIConfiguration.delegateAddress
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        let since = Int64(Date().timeIntervalSince1970)
        let until = Int64(Calendar.current.date(byAdding: intervalUnit, value: intervalValue, to: Date())!.timeIntervalSince1970)
        var order = OriginalOrder(delegate: delegate, address: address, side: side, tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: lrcFee, buyNoMoreThanAmountB: buyNoMoreThanAmountB)
        PlaceOrderDataManager.shared.completeOrder(&order)
        return order
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
        hideNumericKeyboard()
        priceTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        let isPriceValid = validateTokenPrice()
        let isAmountValid = validateAmount()
        if isPriceValid && isAmountValid {
            self.validateAmountRational()
        }
        if !isPriceValid {
            updateLabel(label: estimateValueInCurrencyLabel, enable: true, color: .red, text: LocalizedString("Please input a valid price", comment: ""))
        }
        if !isAmountValid {
            updateLabel(label: tipLabel, enable: true, color: .red, text: LocalizedString("Please input a valid amount", comment: ""))
        }
    }

    func pushController() {
        if let order = constructOrder() {
            let viewController = PlaceOrderConfirmationViewController()
            viewController.order = order
            viewController.type = self.type
            viewController.expire = self.expire
            viewController.price = priceTextField.text!
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func validateAmountRational() {
        if !isAmountValid() {
            let title = LocalizedString("Please Pay Attention", comment: "")
            let message = LocalizedString("Your order amount exceeded your asset balance, which cause your order could not be dealt completely. Do you wish to continue trading with the amount?", comment: "")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.pushController()
                }
            }))
            alert.addAction(UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.pushController()
        }
    }

    func updateLabel(label: UILabel, enable: Bool, color: UIColor? = nil, text: String? = nil) {
        guard enable else {
            label.isHidden = true
            return
        }
        label.isHidden = false
        label.textColor = color
        if color == .red {
            label.shake()
        }
        label.text = text
    }
    
    func isAmountValid() -> Bool {
        var total: Double = 0
        if let balance = getBalance() {
            if type == .buy {
                total = Double(priceTextField.text!)! * Double(amountTextField.text!)!
            } else if type == .sell {
                total = Double(amountTextField.text!)!
            }
            return balance > total
        }
        return true
    }
    
    func validateTokenPrice() -> Bool {
        if let value = Double(priceTextField.text ?? "0") {
            let validate = value > 0.0
            if validate {
                let tokenBPrice = PriceDataManager.shared.getPrice(of: PlaceOrderDataManager.shared.tokenB.symbol)!
                let estimateValue: Double = value * tokenBPrice
                updateLabel(label: estimateValueInCurrencyLabel, enable: true, color: .black, text: "≈ \(estimateValue.currency)")
            } else {
                updateLabel(label: estimateValueInCurrencyLabel, enable: true, color: .red, text: LocalizedString("Please input a valid price", comment: ""))
            }
            return validate
        } else {
            if activeTextFieldTag == priceTextField.tag {
                updateLabel(label: estimateValueInCurrencyLabel, enable: false)
            }
            totalTextField.text = ""
            availableLabel.textColor = .black
            return false
        }
    }
   
    func validateAmount() -> Bool {
        if let value = Double(amountTextField.text ?? "0") {
            let validate = value > 0.0
            if validate {
                if type == .buy {
                    updateLabel(label: tipLabel, enable: false)
                } else {
                    setupLabels()
                }
            } else {
                updateLabel(label: tipLabel, enable: true, color: .red, text: LocalizedString("Please input a valid amount", comment: ""))
            }
            return validate
        } else {
            if activeTextFieldTag == amountTextField.tag {
                if type == .buy {
                    updateLabel(label: tipLabel, enable: false)
                } else {
                    setupLabels()
                }
            }
            totalTextField.text = ""
            availableLabel.textColor = .black
            return false
        }
    }

    func validate() -> Bool {
        var isValid = false
        if activeTextFieldTag == priceTextField.tag {
            isValid = validateTokenPrice()
        } else if activeTextFieldTag == amountTextField.tag {
            isValid = validateAmount()
        }
        guard isValid else {
            totalTextField.text = ""
            return false
        }
        if validateTokenPrice() && validateAmount() {
            isValid = true
            let total = Double(priceTextField.text!)! * Double(amountTextField.text!)!
            totalTextField.text = "\(total)"
            if !isAmountValid() {
                if let balance = getBalance() {
                    let title = LocalizedString("Available Balance", comment: "")
                    if type == .buy {
                        updateLabel(label: availableLabel, enable: true, color: .red, text: "\(title) \(balance.withCommas()) \(PlaceOrderDataManager.shared.tokenB.symbol)")
                    } else if activeTextFieldTag == amountTextField.tag {
                        updateLabel(label: tipLabel, enable: true, color: .red, text: "\(title) \(balance.withCommas()) \(PlaceOrderDataManager.shared.tokenA.symbol)")
                    }
                }
            } else {
                setupLabels()
            }
        } else {
            totalTextField.text = ""
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
    
    func getActiveTextField() -> UITextField? {
        if activeTextFieldTag == priceTextField.tag {
            return priceTextField
        } else if activeTextFieldTag == amountTextField.tag {
            return amountTextField
        } else if activeTextFieldTag == totalTextField.tag {
            return totalTextField
        } else {
            return nil
        }
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.placeOrderBackgroundView.frame.origin.y

            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            view.bringSubview(toFront: placeOrderBackgroundView)
            view.bringSubview(toFront: placeOrderButton)
            
            let destinateY = height - DefaultNumericKeyboard.height
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShow = true
                if finished {
                    if textField.tag == self.totalTextField.tag {
                        let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                        self.scrollView.setContentOffset(bottomOffset, animated: true)
                    }
                }
            })
        } else {
            if textField.tag == totalTextField.tag {
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            self.scrollViewButtonLayoutConstraint.constant = 0
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { finished in
                self.isNumericKeyboardShow = false
                if finished {
                }
            })
        } else {
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        let activeTextField = getActiveTextField()
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
        if activeTextFieldTag == priceTextField.tag {
            customerValue = priceTextField.text!
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
    
    func setResultOfPrice(with tag: Int) {
        var text: String = ""
        let market = PlaceOrderDataManager.shared.market.tradingPair.description
        LoopringAPIRequest.getDepth(market: market, length: 1) { (depth, error) in
            guard depth != nil && error == nil else { return }
            switch tag {
            case 0: // custom
                text = self.customerValue
            case 1: // sell
                if depth!.sell.count > 0 {
                    text = depth!.sell[0].unit
                }
            case 2: // buy
                if depth!.buy.count > 0 {
                    text = depth!.buy[0].unit
                }
            case 3: // market
                let pair = PlaceOrderDataManager.shared.market.description
                if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
                    text = market.balance.description
                }
            default:
                break
            }
            DispatchQueue.main.async {
                if let value = Double(text) {
                    self.priceTextField.text = value.withCommas(6)
                    self.activeTextFieldTag = self.priceTextField.tag
                    _ = self.validate()
                }
            }
        }
    }
    
    func setResultOfAmount(with percentage: Double) {
        if type == .sell {
            self.percentage = percentage
            if let balance = CurrentAppWalletDataManager.shared.getBalance(of: PlaceOrderDataManager.shared.tokenA.symbol) {
                let value = balance * percentage
                amountTextField.text = value.withCommas()
            }
        }
        self.activeTextFieldTag = amountTextField.tag
        _ = self.validate()
    }
}

extension BuyViewController {
    
    func getLrcFee(_ amountS: Double, _ tokenS: String) -> Double {
        var result: Double = 0
        let pair = tokenS + "/LRC"
        let ratio = SettingDataManager.shared.getLrcFeeRatio()
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            result = market.balance * amountS * ratio
        } else if let price = PriceDataManager.shared.getPrice(of: tokenS),
            let lrcPrice = PriceDataManager.shared.getPrice(of: "LRC") {
            result = price * amountS * ratio / lrcPrice
        }
        let minLrc = GasDataManager.shared.getGasAmount(by: "lrcFee", in: "LRC") / 2
        return max(result, minLrc)
    }
}

// MARK: - DefaultSliderDelegate

extension BuyViewController: DefaultSliderDelegate {
    
    func defaultSlider(_ slider: DefaultSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        /*
        if slider === amountSlider {
             print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
            if minValue > 0 {
                amountSlider.tintColor = UIColor.black
            } else {
                amountSlider.tintColor = UIColor.init(white: 0.7, alpha: 1)
            }
        }
        */
    }
    
    func didStartTouches(in slider: DefaultSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: DefaultSlider) {
        print("did end touches")
    }
}
