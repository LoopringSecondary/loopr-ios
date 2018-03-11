//
//  BuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class BuyViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var placeOrderBackgroundView: UIView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    // Price
    var tokenSLabel: UILabel = UILabel()
    var tokenSPriceTextField: UITextField = UITextField()
    var tokenSUnderLine: UIView = UIView()
    var estimateValueInCurrency: UILabel = UILabel()

    // Amout
    var tokenBLabel: UILabel = UILabel()
    var amountTextField: UITextField = UITextField()
    var amountUnderLine: UIView = UIView()
    var maxButton: UIButton = UIButton()

    // Total
    var tokenSTotalLabel: UILabel = UILabel()
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

    // Keyboard
    var isKeyboardShow: Bool = false
    var keyboardView: DefaultNumericKeyboard!
    
    var activeTextFieldTag = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollViewButtonLayoutConstraint.constant = 77

        placeOrderButton.title = NSLocalizedString("Place Order", comment: "")
        placeOrderButton.backgroundColor = UIColor.black
        placeOrderButton.layer.cornerRadius = 23
        placeOrderButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 50
        let padding: CGFloat = 15
        
        // First row: price

        tokenSLabel.text = PlaceOrderDataManager.shared.tokenS
        tokenSLabel.font = FontConfigManager.shared.getLabelFont()
        tokenSLabel.textAlignment = .right
        // tokenSLabel.backgroundColor = UIColor.green
        tokenSLabel.frame = CGRect(x: screenWidth-80-padding, y: originY, width: 80, height: 40)
        scrollView.addSubview(tokenSLabel)
        
        tokenSPriceTextField.delegate = self
        tokenSPriceTextField.tag = 0
        tokenSPriceTextField.inputView = UIView()
        tokenSPriceTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        // tokenSPriceTextField.backgroundColor = UIColor.blue
        tokenSPriceTextField.placeholder = "Limited Price"
        tokenSPriceTextField.contentMode = UIViewContentMode.bottom
        tokenSPriceTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(tokenSPriceTextField)
        
        tokenSUnderLine.frame = CGRect(x: padding, y: tokenSLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        tokenSUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(tokenSUnderLine)

        estimateValueInCurrency.text = "≈ $ 0.00"
        estimateValueInCurrency.font = FontConfigManager.shared.getLabelFont()
        estimateValueInCurrency.frame = CGRect(x: padding, y: tokenSUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        // estimateValueInCurrency.backgroundColor = UIColor.green
        scrollView.addSubview(estimateValueInCurrency)
        
        // Second row: amount
        
        tokenBLabel.text = PlaceOrderDataManager.shared.tokenB
        tokenBLabel.font = FontConfigManager.shared.getLabelFont()
        tokenBLabel.textAlignment = .right
        // tokenBLabel.backgroundColor = UIColor.green
        tokenBLabel.frame = CGRect(x: screenWidth-80-padding, y: estimateValueInCurrency.frame.maxY + 30, width: 80, height: 40)
        scrollView.addSubview(tokenBLabel)
        
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        // amountTextField.backgroundColor = UIColor.blue
        amountTextField.placeholder = "Amount"
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: estimateValueInCurrency.frame.maxY + 30, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountTextField)
        
        amountUnderLine.frame = CGRect(x: padding, y: tokenBLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderLine)

        maxButton.title = "Max"
        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        // maxButton.backgroundColor = UIColor.black
        maxButton.contentHorizontalAlignment = .right
        maxButton.frame = CGRect(x: screenWidth-80-padding, y: amountUnderLine.frame.maxY, width: 80, height: 40)
        scrollView.addSubview(maxButton)
        
        // Thrid row: total
        
        tokenSTotalLabel.text = PlaceOrderDataManager.shared.tokenS
        tokenSTotalLabel.font = FontConfigManager.shared.getLabelFont()
        tokenSTotalLabel.textAlignment = .right
        // tokenSTotalLabel.backgroundColor = UIColor.green
        tokenSTotalLabel.frame = CGRect(x: screenWidth-80-padding, y: maxButton.frame.maxY + 30, width: 80, height: 40)
        scrollView.addSubview(tokenSTotalLabel)
        
        totalTextField.delegate = self
        totalTextField.tag = 2
        totalTextField.inputView = UIView()
        totalTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        // amountTextField.backgroundColor = UIColor.blue
        totalTextField.placeholder = "Total"
        totalTextField.contentMode = UIViewContentMode.bottom
        totalTextField.frame = CGRect(x: padding, y: maxButton.frame.maxY + 30, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(totalTextField)
        
        totalUnderLine.frame = CGRect(x: padding, y: tokenSTotalLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        totalUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(totalUnderLine)
        
        availableLabel.text = "Available 96.3236 ETH"
        availableLabel.font = FontConfigManager.shared.getLabelFont()
        availableLabel.frame = CGRect(x: padding, y: totalUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        // estimateValueInCurrency.backgroundColor = UIColor.green
        scrollView.addSubview(availableLabel)
        
        // Fourth Row
        expireLabel.text = "Order Expires in"
        expireLabel.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        expireLabel.textAlignment = .left
        // expireLabel.backgroundColor = UIColor.green
        expireLabel.frame = CGRect(x: padding, y: availableLabel.frame.maxY + 30, width: 300, height: 40)
        scrollView.addSubview(expireLabel)

        stackView.axis  = UILayoutConstraintAxis.horizontal
        stackView.distribution  = UIStackViewDistribution.fillEqually
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing   = 20.0
        
        oneHourButton.setTitle("1 Hour", for: .normal)
        oneHourButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneHourButton.addTarget(self, action: #selector(self.pressedOneHourButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneHourButton)
        
        oneDayButton.setTitle("1 Day", for: .normal)
        oneDayButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneDayButton.addTarget(self, action: #selector(self.pressedOneDayButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneDayButton)

        oneWeekButton.setTitle("1 Week", for: .normal)
        oneWeekButton.titleLabel?.font = UIFont.init(name: FontConfigManager.shared.getBold(), size: 14)
        oneWeekButton.addTarget(self, action: #selector(self.pressedOneWeekButton(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(oneWeekButton)

        oneMonthButton.setTitle("1 Month", for: .normal)
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
        
        // keyboardView.delegate = self
        // keyboardView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pressedOneHourButton(_ button: UIButton) {
        print("pressOneHourButton")
        oneHourButton.selected()
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
    }
    
    @objc func pressedOneDayButton(_ button: UIButton) {
        print("pressedOneDayButton")
        oneHourButton.unselected()
        oneDayButton.selected()
        oneWeekButton.unselected()
        oneMonthButton.unselected()
    }
    
    @objc func pressedOneWeekButton(_ button: UIButton) {
        print("pressedOneWeekButton")
        oneHourButton.unselected()
        oneDayButton.unselected()
        oneWeekButton.selected()
        oneMonthButton.unselected()
    }
    
    @objc func pressedOneMonthButton(_ button: UIButton) {
        print("pressedOneMonthButton")
        oneHourButton.unselected()
        oneDayButton.unselected()
        oneWeekButton.unselected()
        oneMonthButton.selected()
    }

    @IBAction func pressedPlaceOrderButton(_ sender: Any) {
        print("pressedPlaceOrderButton")
        
        if PlaceOrderDataManager.shared.verify() {
            let viewController = PlaceOrderConfirmationViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        
        activeTextFieldTag = textField.tag

        if !isKeyboardShow {
            let width = self.view.frame.width
            let height = self.placeOrderBackgroundView.frame.origin.y
            
            let keyboardHeight: CGFloat = 220
            
            scrollViewButtonLayoutConstraint.constant = keyboardHeight
            
            keyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: keyboardHeight))
            keyboardView.delegate = self
            // keyboardView.backgroundColor = UIColor.blue
            view.addSubview(keyboardView)
            view.bringSubview(toFront: placeOrderBackgroundView)
            view.bringSubview(toFront: placeOrderButton)
            
            let destinateY = height - keyboardHeight

            // TODO: improve the animation.
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.keyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: keyboardHeight)
            }, completion: { finished in
                self.isKeyboardShow = true
                if finished {
                    if textField.tag == 2 {
                        let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                        self.scrollView.setContentOffset(bottomOffset, animated: true)
                    }
                }
            })
        } else {
            if textField.tag == 2 {
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                self.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }

        return true
    }
    
    func getActiveTextField() -> UITextField? {
        if activeTextFieldTag == tokenSPriceTextField.tag {
            return tokenSPriceTextField
        } else if activeTextFieldTag == amountTextField.tag {
            return amountTextField
        } else if activeTextFieldTag == totalTextField.tag {
            return totalTextField
        } else {
            return nil
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
    }

}
