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
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var convertBackgroundView: UIView!
    
    var asset: Asset?

    var infoLabel: UILabel = UILabel()

    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightButton: UIButton = UIButton()

    // Amout
    var tokenSLabel: UILabel = UILabel()
    var amountTextField: UITextField = UITextField()
    var amountUnderLine: UIView = UIView()
    var availableLabel: UILabel = UILabel()
    var maxButton: UIButton = UIButton()

    // Keyboard
    var isKeyboardShow: Bool = false
    var keyboardView: DefaultNumericKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Convert", comment: "")

        setBackButton()

        scrollViewButtonLayoutConstraint.constant = 0
        
        convertButton.title = NSLocalizedString("Yes, convert now!", comment: "")
        convertButton.backgroundColor = UIColor.black
        convertButton.layer.cornerRadius = 23
        convertButton.titleLabel?.font = FontConfigManager.shared.getButtonTitleLabelFont(size: 16)

        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let padding: CGFloat = 15
        
        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: 0, width: (screenWidth-30)/2, height: 180))
        scrollView.addSubview(tokenSView)
        
        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: 0, width: (screenWidth-30)/2, height: 180))
        scrollView.addSubview(tokenBView)

        arrowRightButton = UIButton(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32, height: 32)))
        let image = UIImage.init(named: "Arrow-right-black")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        arrowRightButton.setImage(tintedImage, for: .normal)
        arrowRightButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        arrowRightButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        arrowRightButton.addTarget(self, action: #selector(self.pressedArrowButton(_:)), for: UIControlEvents.touchUpInside)
        scrollView.addSubview(arrowRightButton)
        
        infoLabel.frame = CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY - 60), size: CGSize(width: 200, height: 21))
        infoLabel.text = asset!.symbol.uppercased() == "ETH" ? "1 ETH = 1 WETH" : "1 WETH = 1 ETH"
        infoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        infoLabel.textAlignment = .center
        scrollView.addSubview(infoLabel)

        // Row 2: Amount
        
        tokenSLabel.text = asset!.symbol
        tokenSLabel.font = FontConfigManager.shared.getLabelFont()
        tokenSLabel.textAlignment = .right
        tokenSLabel.frame = CGRect(x: screenWidth-80-padding, y: tokenSView.frame.maxY + padding, width: 80, height: 40)
        scrollView.addSubview(tokenSLabel)
        
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.placeholder = "Amount"
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: tokenSView.frame.maxY + padding, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountTextField)

        amountUnderLine.frame = CGRect(x: padding, y: tokenSLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderLine)
        
        availableLabel.text = "Available 96.3236 ETH"
        availableLabel.font = FontConfigManager.shared.getLabelFont()
        availableLabel.frame = CGRect(x: padding, y: amountUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(availableLabel)
        
        maxButton.title = "Max"
        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        // maxButton.backgroundColor = UIColor.black
        maxButton.contentHorizontalAlignment = .right
        maxButton.frame = CGRect(x: screenWidth-80-padding, y: amountUnderLine.frame.maxY, width: 80, height: 40)
        maxButton.addTarget(self, action: #selector(self.pressedMaxButton(_:)), for: UIControlEvents.touchUpInside)

        scrollView.addSubview(maxButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Update availableLabel
        if let asset = self.asset {
            let symbol = asset.symbol
            availableLabel.text = "Available \(ConvertDataManager.shared.getMaxAmount(symbol: symbol.uppercased())) \(symbol)"
            tokenSView.update(symbol: symbol)
            tokenBView.update(symbol: getAnotherToken())
        }
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
    
    func updateLabel() {
        tokenSLabel.text = asset!.symbol
        let symbol = asset!.symbol
        infoLabel.text = symbol.uppercased() == "ETH" ? "1 ETH = 1 WETH" : "1 WETH = 1 ETH"
        availableLabel.text = "Available \(ConvertDataManager.shared.getMaxAmount(symbol: symbol.uppercased())) \(symbol)"
    }
    
    @objc func pressedArrowButton(_ sender: Any) {
        print("pressedArrowButton")
        if let asset = self.asset {
            self.asset = getAnotherAsset()
            UIView.transition(with: tokenSView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.tokenSView.update(symbol: self.asset!.symbol) }, completion: nil)
            UIView.transition(with: tokenBView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.tokenBView.update(symbol: asset.symbol) }, completion: nil)
            updateLabel()
        }
    }
    
    @objc func pressedMaxButton(_ sender: Any) {
        print("pressedMaxButton")
        if let asset = self.asset {
            amountTextField.text = String(ConvertDataManager.shared.getMaxAmount(symbol: asset.symbol))
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        showKeyboard(textField: textField)
        return true
    }
    
    func getActiveTextField() -> UITextField? {
        // Only one text field in the view controller.
        return amountTextField
    }
    
    func showKeyboard(textField: UITextField) {
        if !isKeyboardShow {
            let width = self.view.frame.width
            let height = self.convertBackgroundView.frame.origin.y
            
            let keyboardHeight: CGFloat = 220
            
            scrollViewButtonLayoutConstraint.constant = keyboardHeight
            
            keyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: keyboardHeight))
            keyboardView.delegate = self
            view.addSubview(keyboardView)
            view.bringSubview(toFront: convertBackgroundView)
            view.bringSubview(toFront: convertButton)
            
            let destinateY = height - keyboardHeight
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.keyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: keyboardHeight)
                
            }, completion: { _ in
                self.isKeyboardShow = true
            })
        }
    }

    func hideKeyboard() {
        
    }
    
    func completion(_ txHash: String?, _ error: Error?) {
        guard error == nil && txHash != nil else {
            // Show toast
            DispatchQueue.main.async {
                let notificationTitle = NSLocalizedString("Insufficient funds for gas x price + value", comment: "")
                let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
                let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
                let banner = NotificationBanner(attributedTitle: attributeString, style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        print("Result of transfer is \(txHash!)")
        // Show toast
        DispatchQueue.main.async {
            let notificationTitle = NSLocalizedString("Success. Result of transfer is \(txHash!)", comment: "")
            let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
            let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
            let banner = NotificationBanner(attributedTitle: attributeString, style: .success)
            banner.duration = 5
            banner.show()
        }
    }
    
    func validation() -> GethBigInt? {
        var result: GethBigInt? = nil
        if let asset = self.asset {
            if let amountString = amountTextField.text {
                if let amount = Double(amountString) {
                    if asset.balance >= amount {
                        if let amount = GethBigInt.bigInt(amountString) {
                            result = amount
                        }
                    }
                }
            }
        }
        return result
    }
    
    @IBAction func pressedConvertButton(_ sender: Any) {
        guard let amount = validation() else {
            // TODO: tip in ui
            print("Invalid Amount")
            return
        }
        if asset!.symbol.uppercased() == "ETH" {
            SendCurrentAppWalletDataManager.shared._deposit(amount: amount, gasPrice: gasPrice, completion: completion)
        } else if asset!.symbol.uppercased() == "WETH" {
            SendCurrentAppWalletDataManager.shared._withDraw(amount: amount, gasPrice: gasPrice, completion: completion)
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

extension ConvertETHViewController {
    var gasPrice: GethBigInt {
        // TODO: get value from transactionSpeedSlider in advanced setting
        return GethBigInt(20000000000)
    }
}
