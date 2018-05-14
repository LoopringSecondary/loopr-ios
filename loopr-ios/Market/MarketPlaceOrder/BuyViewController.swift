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

class BuyViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

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
    var priceTextField: UITextField = UITextField()
    var tokenAUnderLine: UIView = UIView()
    var estimateValueInCurrencyLabel: UILabel = UILabel()

    // Amout
    var tokenBLabel: UILabel = UILabel()
    var amountTextField: UITextField = UITextField()
    var amountUnderLine: UIView = UIView()
    var tipLabel: UILabel = UILabel()
    var maxButton: UIButton = UIButton()

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
        view.backgroundColor = UIColor.white
        scrollViewButtonLayoutConstraint.constant = 0

        placeOrderButton.title = NSLocalizedString("Place Order", comment: "")
        placeOrderButton.setupRoundBlack()
        placeOrderButton.isEnabled = false
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 50
        let padding: CGFloat = 15
        
        // First row: price
        tokenALabel.text = PlaceOrderDataManager.shared.tokenB.symbol
        tokenALabel.font = FontConfigManager.shared.getLabelFont()
        tokenALabel.textAlignment = .right
        tokenALabel.frame = CGRect(x: screenWidth-80-padding, y: originY, width: 80, height: 40)
        scrollView.addSubview(tokenALabel)
        
        priceTextField.delegate = self
        priceTextField.tag = 0
        priceTextField.inputView = UIView()
        priceTextField.font = FontConfigManager.shared.getLabelFont()
        priceTextField.theme_tintColor = GlobalPicker.textColor
        priceTextField.placeholder = "Price " + PlaceOrderDataManager.shared.market.balance.description
        priceTextField.contentMode = UIViewContentMode.bottom
        priceTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(priceTextField)

        tokenAUnderLine.frame = CGRect(x: padding, y: tokenALabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        tokenAUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(tokenAUnderLine)

        let zeroValue: Double = 0.0
        estimateValueInCurrencyLabel.text = "≈ \(zeroValue.currency)"
        estimateValueInCurrencyLabel.font = FontConfigManager.shared.getLabelFont()
        estimateValueInCurrencyLabel.frame = CGRect(x: padding, y: tokenAUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(estimateValueInCurrencyLabel)
        
        // Second row: amount
        tokenBLabel.text = PlaceOrderDataManager.shared.tokenA.symbol
        tokenBLabel.font = FontConfigManager.shared.getLabelFont()
        tokenBLabel.textAlignment = .right
        tokenBLabel.frame = CGRect(x: screenWidth-80-padding, y: estimateValueInCurrencyLabel.frame.maxY + 30, width: 80, height: 40)
        scrollView.addSubview(tokenBLabel)
        
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.placeholder = "Amount"
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: estimateValueInCurrencyLabel.frame.maxY + 30, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountTextField)
        
        amountUnderLine.frame = CGRect(x: padding, y: tokenBLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderLine)
        
        tipLabel.font = FontConfigManager.shared.getLabelFont()
        tipLabel.frame = CGRect(x: padding, y: amountUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(tipLabel)

        maxButton.title = NSLocalizedString("Max", comment: "")
        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        maxButton.contentHorizontalAlignment = .right
        maxButton.frame = CGRect(x: screenWidth-80-padding, y: amountUnderLine.frame.maxY, width: 80, height: 40)
        scrollView.addSubview(maxButton)
        
        // Thrid row: total
        tokenBTotalLabel.text = PlaceOrderDataManager.shared.tokenB.symbol
        tokenBTotalLabel.font = FontConfigManager.shared.getLabelFont()
        tokenBTotalLabel.textAlignment = .right
        tokenBTotalLabel.frame = CGRect(x: screenWidth-80-padding, y: maxButton.frame.maxY + 30, width: 80, height: 40)
        scrollView.addSubview(tokenBTotalLabel)
        
        totalTextField.delegate = self
        totalTextField.tag = 2
        totalTextField.inputView = UIView()
        totalTextField.font = FontConfigManager.shared.getLabelFont()
        totalTextField.theme_tintColor = GlobalPicker.textColor
        totalTextField.placeholder = "Total"
        totalTextField.contentMode = UIViewContentMode.bottom
        totalTextField.frame = CGRect(x: padding, y: maxButton.frame.maxY + 30, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(totalTextField)

        // Disable user input in totalTextField
        totalTextField.isEnabled = false

        totalUnderLine.frame = CGRect(x: padding, y: tokenBTotalLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        totalUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(totalUnderLine)

        if let balance = getSellingBalance() {
            availableLabel.text = "Available \(balance) \(PlaceOrderDataManager.shared.tokenB.symbol)"
        }
        availableLabel.font = FontConfigManager.shared.getLabelFont()
        availableLabel.frame = CGRect(x: padding, y: totalUnderLine.frame.maxY, width: screenWidth-padding*2, height: 40)
        scrollView.addSubview(availableLabel)
        
        // Fourth Row
        expireLabel.text = NSLocalizedString("Order Expires in", comment: "")
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
        
        scrollView.contentSize = CGSize(width: screenWidth, height: stackView.frame.maxY + 30)

        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getSellingBalance() -> Double? {
        if type == .buy {
            if let asset = CurrentAppWalletDataManager.shared.getAsset(symbol: PlaceOrderDataManager.shared.tokenB.symbol) {
                return asset.balance
            }
        }
        return nil
    }
    
    func checkEmpty() -> Bool {
        guard CurrentAppWalletDataManager.shared.getCurrentAppWallet() != nil else {
            return false
        }
        guard !priceTextField.text!.isEmpty else {
            return false
        }
        guard !amountTextField.text!.isEmpty else {
            return false
        }
        return true
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
        lrcFee = getLrcFee(amountSell, tokenSell)!
        let delegate = RelayAPIConfiguration.delegateAddress
        let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address
        let since = Int64(Date().timeIntervalSince1970)
        let until = Int64(Calendar.current.date(byAdding: intervalUnit, value: intervalValue, to: Date())!.timeIntervalSince1970)
        return OriginalOrder(delegate: delegate, address: address, side: side, tokenS: tokenSell, tokenB: tokenBuy, validSince: since, validUntil: until, amountBuy: amountBuy, amountSell: amountSell, lrcFee: lrcFee, buyNoMoreThanAmountB: buyNoMoreThanAmountB)
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
        self.validatePriceRational()
    }

    func updateButton(isValid: Bool) {
        placeOrderButton.isEnabled = isValid
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
    
    func validatePriceRational() {
        let pair = PlaceOrderDataManager.shared.market.description
        if let market = MarketDataManager.shared.getMarket(byTradingPair: pair) {
            let value = Double(priceTextField.text!)!
            // TODO: get from setting maybe
            if value < 0.8 * market.balance || value > 1.2 * market.balance {
                let title = NSLocalizedString("Your setting price is IRRATIONAL, Do you want to continue trading with the price?", comment: "")
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
        }
    }

    func validateTokenPrice() -> Bool {
        guard !priceTextField.text!.isEmpty else {
            return false
        }
        if let value = Double(priceTextField.text ?? "0") {
            let validate = value > 0.0
            if validate {
                let tokenBPrice = PriceDataManager.shared.getPriceBySymbol(of: PlaceOrderDataManager.shared.tokenB.symbol)!
                let estimateValue: Double = value * tokenBPrice
                estimateValueInCurrencyLabel.textColor = .black
                estimateValueInCurrencyLabel.text = "≈ \(estimateValue.currency)"
            } else {
                estimateValueInCurrencyLabel.textColor = .red
                estimateValueInCurrencyLabel.text = NSLocalizedString("please input a valid price", comment: "")
            }
            return validate
        } else {
            return false
        }
    }
    
    func validateAmount() -> Bool {
        guard !amountTextField.text!.isEmpty else {
            return false
        }
        if let value = Double(amountTextField.text ?? "0") {
            let validate = value > 0.0
            if validate {
                tipLabel.isHidden = true
            } else {
                tipLabel.isHidden = false
                tipLabel.textColor = .red
                tipLabel.text = NSLocalizedString("please input a valid amount", comment: "")
            }
            return validate
        } else {
            return false
        }
    }

    func validate() -> Bool {
        var isValid = false
        if activeTextFieldTag == priceTextField.tag {
            _ = validateTokenPrice()
        } else if activeTextFieldTag == amountTextField.tag {
            _ = validateAmount()
        }
        if validateTokenPrice() && validateAmount() {
            isValid = true
            let total = Double(priceTextField.text ?? "0")! * Double(amountTextField.text ?? "0")!
            totalTextField.text = "\(total)"
            if let balance = getSellingBalance() {
                if balance < total {
                    availableLabel.textColor = .red
                } else {
                    availableLabel.textColor = .black
                }
            }
        } else {
            totalTextField.text = ""
        }
        updateButton(isValid: isValid)
        return isValid
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        activeTextFieldTag = textField.tag
        showNumericKeyboard(textField: textField)
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

    @objc func priceTextFieldDidChange(_ textField: UITextField) {
        print("priceTextFieldDidChange")
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

extension BuyViewController {
    
    func getLrcFee(_ amountS: Double, _ tokenS: String) -> Double? {
        return TradeDataManager.shared.getLrcFee(amountS, tokenS)
    }
}
