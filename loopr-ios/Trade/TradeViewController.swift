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
    var tokenSPriceTextField: UITextField = UITextField()
    var tokenSUnderLine: UIView = UIView()
    var estimateValueInCurrency: UILabel = UILabel()
    
    // Exchange label
    var exchangeLabel: UILabel = UILabel()
    
    // TokenB
    var tokenBButton: UIButton = UIButton()
    var totalTextField: UITextField = UITextField()
    var totalUnderLine: UIView = UIView()
    var availableLabel: UILabel = UILabel()

    // Keyboard
    var isKeyboardShown: Bool = false
    var keyboardView: DefaultNumericKeyboard!

    var activeTextFieldTag = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollViewButtonLayoutConstraint.constant = 0
        
        nextButton.title = NSLocalizedString("Next", comment: "")
        nextButton.backgroundColor = UIColor.black
        nextButton.layer.cornerRadius = 23
        nextButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 16.0)
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 60
        let padding: CGFloat = 15
        
        // First row: TokenS

        tokenSButton.setTitleColor(UIColor.black, for: .normal)
        tokenSButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        tokenSButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        tokenSButton.frame = CGRect(x: screenWidth-55-padding, y: originY, width: 80, height: 40)
        tokenSButton.addTarget(self, action: #selector(pressedSwitchTokenSButton), for: .touchUpInside)
        scrollView.addSubview(tokenSButton)
        
        tokenSPriceTextField.delegate = self
        tokenSPriceTextField.tag = 0
        tokenSPriceTextField.inputView = UIView()
        tokenSPriceTextField.font = FontConfigManager.shared.getLabelFont()
        tokenSPriceTextField.placeholder = "Enter the amount you have"
        tokenSPriceTextField.contentMode = UIViewContentMode.bottom
        tokenSPriceTextField.frame = CGRect(x: padding, y: originY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(tokenSPriceTextField)
        
        tokenSUnderLine.frame = CGRect(x: padding, y: tokenSButton.frame.maxY, width: screenWidth - padding * 2, height: 1)
        tokenSUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(tokenSUnderLine)
        
        estimateValueInCurrency.text = "≈ $ 0.00"
        estimateValueInCurrency.font = FontConfigManager.shared.getLabelFont()
        estimateValueInCurrency.frame = CGRect(x: padding, y: tokenSUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        // estimateValueInCurrency.backgroundColor = UIColor.green
        scrollView.addSubview(estimateValueInCurrency)
        
        // Second row: exchange label
        
        exchangeLabel.text = "Exchange"
        exchangeLabel.font = FontConfigManager.shared.getLabelFont()
        exchangeLabel.textAlignment = .center
        exchangeLabel.frame = CGRect(x: (screenWidth-120)*0.5, y: estimateValueInCurrency.frame.maxY + padding*2, width: 120, height: 40)
        scrollView.addSubview(exchangeLabel)
        
        // Thrid row: TokenB

        tokenBButton.setTitleColor(UIColor.black, for: .normal)
        tokenBButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        tokenBButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        tokenBButton.frame = CGRect(x: screenWidth-55-padding, y: exchangeLabel.frame.maxY + padding*2, width: 80, height: 40)
        tokenBButton.addTarget(self, action: #selector(pressedSwitchTokenBButton), for: .touchUpInside)
        scrollView.addSubview(tokenBButton)
        
        totalTextField.delegate = self
        totalTextField.tag = 2
        totalTextField.inputView = UIView()
        totalTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        // amountTextField.backgroundColor = UIColor.blue
        totalTextField.placeholder = "Enter the amount you get"
        totalTextField.contentMode = UIViewContentMode.bottom
        totalTextField.frame = CGRect(x: padding, y: exchangeLabel.frame.maxY + padding*2, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(totalTextField)
        
        totalUnderLine.frame = CGRect(x: padding, y: tokenBButton.frame.maxY, width: screenWidth - padding * 2, height: 1)
        totalUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(totalUnderLine)
        
        availableLabel.text = "Available 96.3236 ETH"
        availableLabel.font = FontConfigManager.shared.getLabelFont()
        availableLabel.frame = CGRect(x: padding, y: totalUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        // estimateValueInCurrency.backgroundColor = UIColor.green
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
        tokenBButton.setTitle(TradeDataManager.shared.tokenB.symbol, for: .normal)
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")

        tokenSPriceTextField.resignFirstResponder()
        totalTextField.resignFirstResponder()

        hideKeyboard()
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
        
        // Get the latest value from TextFields
        TradeDataManager.shared.amountTokenS = Double(tokenSPriceTextField.text ?? "") ?? 0
        TradeDataManager.shared.amountTokenB = Double(totalTextField.text ?? "") ?? 0
        
        let viewController = TradeReviewViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")

        activeTextFieldTag = textField.tag
        
        showKeyboard(textField: textField)

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    func getActiveTextField() -> UITextField? {
        if activeTextFieldTag == tokenSPriceTextField.tag {
            return tokenSPriceTextField
        } else if activeTextFieldTag == totalTextField.tag {
            return totalTextField
        } else {
            return nil
        }
    }
    
    func showKeyboard(textField: UITextField) {
        if !isKeyboardShown {
            let width = self.view.frame.width
            let height = self.nextBackgroundView.frame.origin.y
            
            let keyboardHeight: CGFloat = 220
            
            scrollViewButtonLayoutConstraint.constant = keyboardHeight
            
            keyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: keyboardHeight))
            keyboardView.delegate = self
            view.addSubview(keyboardView)
            view.bringSubview(toFront: nextBackgroundView)
            view.bringSubview(toFront: nextButton)
            
            let destinateY = height - keyboardHeight
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.keyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: keyboardHeight)
                
            }, completion: { finished in
                self.isKeyboardShown = true
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
    
    func hideKeyboard() {
        if isKeyboardShown {
            let width = self.view.frame.width
            let height = self.nextBackgroundView.frame.origin.y
            
            let keyboardHeight: CGFloat = 220

            let destinateY = height
            
            self.scrollViewButtonLayoutConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                // animation for layout constraint change.
                self.view.layoutIfNeeded()

                self.keyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: keyboardHeight)
                
            }, completion: { finished in
                self.isKeyboardShown = false
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
    }

}
