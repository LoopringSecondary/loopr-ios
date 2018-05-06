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
    @IBOutlet weak var convertBackgroundViewHeightConstraint: NSLayoutConstraint!
    
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

    // Numeric Keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Convert", comment: "")

        setBackButton()

        scrollViewButtonLayoutConstraint.constant = 0
        convertBackgroundViewHeightConstraint.constant = 47*UIStyleConfig.scale + 15*2

        convertButton.title = NSLocalizedString("Yes, convert now!", comment: "")
        convertButton.setupRoundBlack()

        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let padding: CGFloat = 15*UIStyleConfig.scale
        
        tokenSView = TradeTokenView(frame: CGRect(x: 10, y: 0, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenSView)
        
        tokenBView = TradeTokenView(frame: CGRect(x: (screenWidth+10)/2, y: 0, width: (screenWidth-30)/2, height: 180*UIStyleConfig.scale))
        scrollView.addSubview(tokenBView)

        arrowRightButton = UIButton(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32*UIStyleConfig.scale, height: 32*UIStyleConfig.scale)))
        let image = UIImage.init(named: "Arrow-right-black")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        arrowRightButton.setImage(tintedImage, for: .normal)
        arrowRightButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        arrowRightButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        arrowRightButton.addTarget(self, action: #selector(self.pressedArrowButton(_:)), for: UIControlEvents.touchUpInside)
        scrollView.addSubview(arrowRightButton)
        
        infoLabel.frame = CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY - 60), size: CGSize(width: 200, height: 21*UIStyleConfig.scale))
        infoLabel.text = asset!.symbol.uppercased() == "ETH" ? "1 ETH = 1 WETH" : "1 WETH = 1 ETH"
        infoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16*UIStyleConfig.scale)
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
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: tokenSView.frame.maxY + padding, width: screenWidth-padding*2-80, height: 40)
        amountTextField.placeholder = NSLocalizedString("Amount you want to convert", comment: "")
        scrollView.addSubview(amountTextField)

        amountUnderLine.frame = CGRect(x: padding, y: tokenSLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderLine)
        
        availableLabel.text = ""
        availableLabel.font = FontConfigManager.shared.getLabelFont()
        availableLabel.frame = CGRect(x: padding, y: amountUnderLine.frame.maxY, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(availableLabel)
        
        maxButton.title = NSLocalizedString("Max", comment: "")
        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        // maxButton.backgroundColor = UIColor.black
        maxButton.contentHorizontalAlignment = .right
        maxButton.frame = CGRect(x: screenWidth-80-padding, y: amountUnderLine.frame.maxY, width: 80, height: 40)
        maxButton.addTarget(self, action: #selector(self.pressedMaxButton(_:)), for: UIControlEvents.touchUpInside)
        scrollView.addSubview(maxButton)
        
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
        // TODO: Update availableLabel
        if let asset = self.asset {
            let symbol = asset.symbol
            availableLabel.text = "Available \(ConvertDataManager.shared.getMaxAmount(symbol: symbol.uppercased())) \(symbol)"
            tokenSView.update(symbol: symbol)
            tokenBView.update(symbol: getAnotherToken())
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        amountTextField.resignFirstResponder()
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
    
    func updateLabel() {
        tokenSLabel.text = asset!.symbol
        let symbol = asset!.symbol.uppercased()
        infoLabel.text = symbol == "ETH" ? "1 ETH = 1 WETH" : "1 WETH = 1 ETH"
        let maxAmount = ConvertDataManager.shared.getMaxAmount(symbol: symbol)
        availableLabel.text = "Available \(maxAmount) \(symbol)"
        availableLabel.textColor = .black
        if let text = amountTextField.text, let inputAmount = Double(text) {
            if inputAmount > maxAmount {
                availableLabel.textColor = .red
            }
        }
    }
    
    @objc func pressedArrowButton(_ sender: Any) {
        print("pressedArrowButton")
        if let asset = self.asset {
            self.asset = getAnotherAsset()
            UIView.transition(with: tokenSView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.tokenSView.update(symbol: self.asset?.symbol ?? "") }, completion: nil)
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountTextField.becomeFirstResponder() //Optional

    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        showNumericKeyboard(textField: textField)
        return true
    }

    func getActiveTextField() -> UITextField? {
        // Only one text field in the view controller.
        return amountTextField
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.convertBackgroundView.frame.origin.y
                        
            scrollViewButtonLayoutConstraint.constant = DefaultNumericKeyboard.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            view.bringSubview(toFront: convertBackgroundView)
            view.bringSubview(toFront: convertButton)
            
            let destinateY = height - DefaultNumericKeyboard.height
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                
            }, completion: { _ in
                self.isNumericKeyboardShow = true
            })
        }
    }

    func hideNumericKeyboard() {
        
    }

    func completion(_ txHash: String?, _ error: Error?) {
        guard error == nil && txHash != nil else {
            // Show toast
            DispatchQueue.main.async {
                let banner = NotificationBanner.generate(title: "Insufficient funds for gas x price + value", style: .danger)
                banner.duration = 5
                banner.show()
            }
            return
        }
        print("Result of transfer is \(txHash!)")
        // Show toast
        DispatchQueue.main.async {
            let banner = NotificationBanner.generate(title: "Success. Result of transfer is \(txHash!)", style: .success)
            banner.duration = 5
            banner.show()
        }
    }
    
    func validation() -> GethBigInt? {
        var result: GethBigInt? = nil
        // TODO: improve the following logic in the future.
        if let asset = self.asset {
            if let amountString = amountTextField.text {
                if let amount = Double(amountString) {
                    if asset.balance >= amount {
                        if let token = TokenDataManager.shared.getTokenBySymbol(asset.symbol) {
                            result = GethBigInt.generate(valueInEther: amountString, symbol: token.symbol)
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
        updateLabel()
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

extension ConvertETHViewController {
    var gasPrice: GethBigInt {
        // TODO: get value from transactionSpeedSlider in advanced setting
        return GethBigInt(20000000000)
    }
}
