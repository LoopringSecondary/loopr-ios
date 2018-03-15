//
//  TradeBuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeBuyViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextBackgroundView: UIView!
    @IBOutlet weak var nextButton: UIButton!

    // TokenS
    var tokenSLabel: UILabel = UILabel()
    var tokenSPriceTextField: UITextField = UITextField()
    var tokenSUnderLine: UIView = UIView()
    var estimateValueInCurrency: UILabel = UILabel()
    
    // Exchange label
    var exchangeLabel: UILabel = UILabel()
    
    // TokenB
    var tokenSTotalLabel: UILabel = UILabel()
    var totalTextField: UITextField = UITextField()
    var totalUnderLine: UIView = UIView()
    var availableLabel: UILabel = UILabel()

    // Keyboard
    var isKeyboardShow: Bool = false
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
        let padding: CGFloat = 25
        
        // First row: TokenS

        tokenSLabel.text = "LRC"
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
        tokenSPriceTextField.placeholder = "Enter the amount you have"
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
        
        // Second row: exchange label
        
        exchangeLabel.text = "Exchange"
        exchangeLabel.font = FontConfigManager.shared.getLabelFont()
        exchangeLabel.textAlignment = .center
        exchangeLabel.frame = CGRect(x: (screenWidth-120)*0.5, y: estimateValueInCurrency.frame.maxY + padding*2, width: 120, height: 40)
        scrollView.addSubview(exchangeLabel)
        
        // Thrid row: TokenB
        
        tokenSTotalLabel.text = "BNB"
        tokenSTotalLabel.font = FontConfigManager.shared.getLabelFont()
        tokenSTotalLabel.textAlignment = .right
        // tokenSTotalLabel.backgroundColor = UIColor.green
        tokenSTotalLabel.frame = CGRect(x: screenWidth-80-padding, y: exchangeLabel.frame.maxY + padding*2, width: 80, height: 40)
        scrollView.addSubview(tokenSTotalLabel)
        
        totalTextField.delegate = self
        totalTextField.tag = 2
        totalTextField.inputView = UIView()
        totalTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        // amountTextField.backgroundColor = UIColor.blue
        totalTextField.placeholder = "Enter the amount you get"
        totalTextField.contentMode = UIViewContentMode.bottom
        totalTextField.frame = CGRect(x: padding, y: exchangeLabel.frame.maxY + padding*2, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(totalTextField)
        
        totalUnderLine.frame = CGRect(x: padding, y: tokenSTotalLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
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
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")

        tokenSPriceTextField.resignFirstResponder()
        totalTextField.resignFirstResponder()

        hideKeyboard()
    }
    
    @IBAction func pressedNextButton(_ sender: Any) {
        print("pressedNextButton")
        let viewController = TradeConfirmationViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")

        activeTextFieldTag = textField.tag
        
        showKeyboard(textField: textField)

        return true
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
        if !isKeyboardShow {
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
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.keyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: keyboardHeight)
                
            }, completion: { finished in
                self.isKeyboardShow = true
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
        if isKeyboardShow {
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
                self.isKeyboardShow = false
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
