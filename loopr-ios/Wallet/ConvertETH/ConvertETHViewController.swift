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
    @IBOutlet weak var tokenSImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tokenBImageView: UIImageView!
    @IBOutlet weak var amountSTextField: UITextField!
    @IBOutlet weak var tokenSLabel: UILabel!
    @IBOutlet weak var amountBTextField: UITextField!
    @IBOutlet weak var tokenBLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var gasInfoLabel: UILabel!
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var totalMaskView: UIView!
    
    var asset: Asset?
    var tipMessage: String!
    
    // Numeric Keyboard
    var isNumericKeyboardShow: Bool = false
    var numericKeyboardView: DefaultNumericKeyboard!
    
    var gasPriceInGwei: Double = GasDataManager.shared.getGasPriceInGwei()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SendCurrentAppWalletDataManager.shared.getNonceFromEthereum()
        self.asset = CurrentAppWalletDataManager.shared.getAsset(symbol: "ETH")
        
        self.navigationItem.title = LocalizedString("Convert", comment: "")
        
        setBackButton()
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        tokenSImageView.image = asset?.icon
        tokenBImageView.image = getAnotherAsset()?.icon
        
        infoLabel.setSubTitleCharFont()
        infoLabel.text = LocalizedString("ETH_TIP", comment: "")
        
        amountSTextField.delegate = self
        amountSTextField.inputView = UIView()
        
        tokenSLabel.theme_textColor = GlobalPicker.contrastTextColor
        tokenSLabel.font = FontConfigManager.shared.getLightFont(size: 14)
        tokenBLabel.theme_textColor = GlobalPicker.contrastTextColor
        tokenBLabel.font = FontConfigManager.shared.getLightFont(size: 14)
        
        availableLabel.setSubTitleCharFont()
        maxButton.titleLabel?.setSubTitleCharFont()
        maxButton.title = LocalizedString("Max", comment: "")
        
        gasTipLabel.setTitleCharFont()
        gasTipLabel.text = LocalizedString("Transaction Fee", comment: "")
        gasInfoLabel.setTitleCharFont()
        
        convertButton.title = LocalizedString("Yes, convert now!", comment: "")
        convertButton.setupSecondary(height: 40)
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        
        GasDataManager.shared.getEstimateGasPrice { (gasPrice, _) in
            self.gasPriceInGwei = Double(gasPrice)
            DispatchQueue.main.async {
                self.updateTransactionFeeAmountLabel()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update()
    }
    
    func updateTransactionFeeAmountLabel() {
        let amountInEther = gasPriceInGwei / 1000000000
        if let etherPrice = PriceDataManager.shared.getPrice(of: "ETH") {
            let amont = amountInEther * Double(GasDataManager.shared.getGasLimit(by: "token_transfer")!)
            let transactionFeeInFiat = amont * etherPrice
            gasInfoLabel.text = "\(amont.withCommas(6)) ETH ≈ \(transactionFeeInFiat.currency)"
        }
    }
    
    func update() {
        if let asset = self.asset {
            let symbol = asset.symbol
            let available = ConvertDataManager.shared.getMaxAmount(symbol: symbol)
            let title = LocalizedString("Available Balance", comment: "")
            self.tipMessage = "\(title) \(available.withCommas(6)) \(symbol)"
            availableLabel.text = self.tipMessage
            
            if symbol == "ETH" {
                tokenSLabel.text = "ETH"
                tokenBLabel.text = "WETH"
                infoLabel.isHidden = false
            } else if symbol == "WETH" {
                tokenSLabel.text = "WETH"
                tokenBLabel.text = "ETH"
                infoLabel.isHidden = true
            }
            var width = tokenSLabel.intrinsicContentSize.width + 4
            amountSTextField.setLeftPaddingPoints(width)
            width = tokenBLabel.intrinsicContentSize.width + 4
            amountBTextField.setRightPaddingPoints(width)
        }
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        amountSTextField.resignFirstResponder()
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
    
    @IBAction func pressedArrowButton(_ sender: UIButton) {
        if let asset = self.asset {
            self.asset = getAnotherAsset()
            UIView.transition(with: tokenSImageView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.tokenSImageView.image = self.asset?.icon; self.tokenBImageView.image = asset.icon }, completion: nil)
            UIView.transition(with: tokenBImageView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.tokenBImageView.image = asset.icon }, completion: nil)
            update()
            _ = validate()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountSTextField.becomeFirstResponder() //Optional
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        showNumericKeyboard(textField: textField)
        return true
    }

    func getActiveTextField() -> UITextField? {
        // Only one text field in the view controller.
        return amountSTextField
    }
    
    func showNumericKeyboard(textField: UITextField) {
        if !isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            
            numericKeyboardView = DefaultNumericKeyboard(frame: CGRect(x: 0, y: height, width: width, height: DefaultNumericKeyboard.height))
            numericKeyboardView.delegate = self
            view.addSubview(numericKeyboardView)
            
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            let destinateY = height - DefaultNumericKeyboard.height - bottomPadding
            
            // TODO: improve the animation.
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
                self.scrollView.setContentOffset(CGPoint.zero, animated: false)
            }, completion: { _ in
                self.isNumericKeyboardShow = true
            })
        }
    }
    
    func hideNumericKeyboard() {
        if isNumericKeyboardShow {
            let width = self.view.frame.width
            let height = self.view.frame.height
            let destinateY = height
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.numericKeyboardView.frame = CGRect(x: 0, y: destinateY, width: width, height: DefaultNumericKeyboard.height)
            }, completion: { _ in
                self.isNumericKeyboardShow = false
            })
        }
    }

    func completion(_ txHash: String?, _ error: Error?) {
        guard error == nil && txHash != nil else {
            DispatchQueue.main.async {
                let banner = NotificationBanner.generate(title: "Insufficient funds for gas x price + value", style: .danger)
                banner.duration = 3
                banner.show()
            }
            return
        }
        print("Result of transfer is \(txHash!)")
        DispatchQueue.main.async {
            let banner = NotificationBanner.generate(title: "Success. Result of transfer is \(txHash!)", style: .success)
            banner.duration = 3
            banner.show()
        }
    }
    
    func validate() -> GethBigInt? {
        var result: GethBigInt? = nil
        if let text = amountSTextField.text,
            let inputAmount = Double(text), let maxAmount = asset?.balance {
            if inputAmount > 0 {
                if inputAmount > maxAmount {
                    availableLabel.shake()
                    availableLabel.textColor = .fail
                    availableLabel.text = self.tipMessage
                } else {
                    amountBTextField.text = amountSTextField.text
                    result = GethBigInt.generate(inputAmount)
                    availableLabel.textColor = UIColor.text1
                    availableLabel.text = PriceDataManager.shared.getPrice(of: asset!.symbol, by: inputAmount)
                }
            } else {
                availableLabel.shake()
                availableLabel.textColor = .fail
                availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            }
        } else {
            if amountSTextField.text == "" {
                availableLabel.text = self.tipMessage
                availableLabel.textColor = UIColor.text1
                amountBTextField.text = ""
            } else {
                availableLabel.textColor = .fail
                availableLabel.shake()
                availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            }
        }
        return result
    }
    
    @IBAction func pressedMaxButton(_ sender: UIButton) {
        if let asset = self.asset {
            let amount = ConvertDataManager.shared.getMaxAmountString(asset.symbol)
            amountSTextField.text = amount
            amountBTextField.text = amount
            _ = validate()
        }
    }
    
    @IBAction func pressedAdvanceButton(_ sender: UIButton) {
        self.totalMaskView.alpha = 0.75
        let vc = SetGasViewController()
        vc.recGasPriceInGwei = self.gasPriceInGwei
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        vc.dismissClosure = {
            self.totalMaskView.alpha = 0
            self.gasPriceInGwei = vc.gasPriceInGwei
            self.updateTransactionFeeAmountLabel()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func pressedConvertButton(_ sender: Any) {
        guard let amount = validate() else {
            availableLabel.textColor = .fail
            availableLabel.text = LocalizedString("Please input a valid amount", comment: "")
            availableLabel.shake()
            return
        }
        if asset!.symbol.uppercased() == "ETH" {
            SendCurrentAppWalletDataManager.shared._deposit(amount: amount, completion: completion)
        } else if asset!.symbol.uppercased() == "WETH" {
            SendCurrentAppWalletDataManager.shared._withDraw(amount: amount, completion: completion)
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
        update()
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
