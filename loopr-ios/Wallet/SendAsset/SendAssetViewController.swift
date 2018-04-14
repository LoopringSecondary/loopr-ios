//
//  SendAssetViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import NotificationBannerSwift

class SendAssetViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

    var asset: Asset?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBackgroundView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonLayoutContraint: NSLayoutConstraint!

    // Token
    var tokenIconImageView = UIImageView()
    var tokenTotalAmountLabel = UILabel()

    // Address
    var addressTextField: UITextField = UITextField()
    var scanButton: UIButton = UIButton()
    var addressUnderLine: UIView = UIView()
    var addressInfoLabel: UILabel = UILabel()

    // Amount
    var amountTextField: UITextField = UITextField()
    var tokenSymbolLabel: UILabel = UILabel()
    var amountUnderline: UIView = UIView()
    var amountInfoLabel: UILabel = UILabel()
    var maxButton: UIButton = UIButton()
    
    // Transaction Fee
    var transactionFeeLabel = UILabel()
    var transactionFeeAmountLabel = UILabel()
    
    // Advanced
    var advancedLabel = UILabel()
    var transactionSpeedSlider = UISlider()
    
    // Keyboard
    var isKeyboardShow: Bool = false
    var keyboardView: DefaultNumericKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()

        sendButton.title = NSLocalizedString("Send", comment: "")
        sendButton.setupRoundBlack()
        
        scrollViewButtonLayoutConstraint.constant = 77
        sendButtonLayoutContraint.constant = 15
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 50
        let padding: CGFloat = 15
        
        // First row: token
        tokenIconImageView.frame = CGRect(center: CGPoint(x: screenWidth*0.5, y: originY), size: CGSize(width: 54, height: 54))
        tokenIconImageView.image = UIImage(named: "ETH")
        scrollView.addSubview(tokenIconImageView)
        
        tokenTotalAmountLabel.frame = CGRect(center: CGPoint(x: screenWidth*0.5, y: tokenIconImageView.frame.maxY + 30), size: CGSize(width: screenWidth - 2*padding, height: 21))
        tokenTotalAmountLabel.textAlignment = .center
        tokenTotalAmountLabel.font = FontConfigManager.shared.getLabelFont()
        scrollView.addSubview(tokenTotalAmountLabel)
        
        // Second row: address

        addressTextField.delegate = self
        addressTextField.tag = 0
        addressTextField.font = FontConfigManager.shared.getLabelFont()
        addressInfoLabel.theme_tintColor = GlobalPicker.textColor
        addressTextField.placeholder = "Enter the address"
        addressTextField.contentMode = UIViewContentMode.bottom
        addressTextField.frame = CGRect(x: padding, y: tokenTotalAmountLabel.frame.maxY + padding*3, width: screenWidth-padding*2, height: 40)
        scrollView.addSubview(addressTextField)
        
        addressUnderLine.frame = CGRect(x: padding, y: addressTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        addressUnderLine.backgroundColor = UIColor.black
        scrollView.addSubview(addressUnderLine)

        addressInfoLabel.frame = CGRect(x: padding, y: addressUnderLine.frame.maxY, width: screenWidth - padding * 2, height: 40)
        addressInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
        addressInfoLabel.text = "Please confirm the address before sending."
        scrollView.addSubview(addressInfoLabel)
        
        // Third row: Amount
        
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getLabelFont()
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.placeholder = "Enter the amount"
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: addressInfoLabel.frame.maxY + padding*1.5, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountTextField)

        tokenSymbolLabel.font = FontConfigManager.shared.getLabelFont()
        tokenSymbolLabel.textAlignment = .right
        tokenSymbolLabel.frame = CGRect(x: screenWidth-padding-80, y: amountTextField.frame.origin.y, width: 80, height: 40)
        scrollView.addSubview(tokenSymbolLabel)
        
        amountUnderline.frame = CGRect(x: padding, y: amountTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountUnderline.backgroundColor = UIColor.black
        scrollView.addSubview(amountUnderline)
        
        amountInfoLabel.frame = CGRect(x: padding, y: amountUnderline.frame.maxY, width: screenWidth - padding * 2, height: 40)
        amountInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
        amountInfoLabel.text = "$ 319,491.31"
        scrollView.addSubview(amountInfoLabel)
        
        maxButton.title = "Max"
        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
        maxButton.contentHorizontalAlignment = .right
        maxButton.frame = CGRect(x: screenWidth-80-padding, y: amountUnderline.frame.maxY, width: 80, height: 40)
        maxButton.addTarget(self, action: #selector(self.pressedMaxButton(_:)), for: UIControlEvents.touchUpInside)
        scrollView.addSubview(maxButton)
        
        transactionFeeLabel.frame = CGRect(x: padding, y: maxButton.frame.maxY + padding*2, width: 120, height: 40)
        transactionFeeLabel.font = FontConfigManager.shared.getLabelFont()
        transactionFeeLabel.text = "Transaction Fee"
        scrollView.addSubview(transactionFeeLabel)
        
        transactionFeeAmountLabel.frame = CGRect(x: screenWidth-300-padding, y: maxButton.frame.maxY + padding*2, width: 300, height: 40)
        transactionFeeAmountLabel.font = FontConfigManager.shared.getLabelFont()
        transactionFeeAmountLabel.textAlignment = .right
        transactionFeeAmountLabel.text = "1.232 LRC = $1.46"
        scrollView.addSubview(transactionFeeAmountLabel)

        // Fouth row: Advanced
        
        advancedLabel.frame = CGRect(x: padding, y: transactionFeeAmountLabel.frame.maxY + padding, width: 120, height: 40)
        advancedLabel.font = FontConfigManager.shared.getLabelFont()
        advancedLabel.text = "Advanced"
        scrollView.addSubview(advancedLabel)
        
        transactionSpeedSlider.frame = CGRect(x: padding, y: advancedLabel.frame.maxY + padding*0.5, width: screenWidth-2*padding, height: 20)
        
        // TODO: Set value
        transactionSpeedSlider.minimumValue = 0
        transactionSpeedSlider.maximumValue = 100
        
        transactionSpeedSlider.isContinuous = true
        transactionSpeedSlider.tintColor = UIColor.black
        transactionSpeedSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        scrollView.addSubview(transactionSpeedSlider)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: screenWidth, height: transactionSpeedSlider.frame.maxY + 30)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)

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
        
        // TODO: Update the transaction fee is needed. in SendCurrentAppWalletDataManager
        addressTextField.text = "0x2ef680f87989bce2a9f458e450cffd6589b549fa"
        amountTextField.text = "0.1"
        
        tokenSymbolLabel.text = asset?.symbol ?? ""
        
        // TODO: Use mock data
        tokenTotalAmountLabel.text = "123123.422 \(String(describing: asset!.symbol)) Available"
    }
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        
        addressTextField.resignFirstResponder()
        
        hideKeyboard()
    }

    @IBAction func pressedSendButton(_ sender: Any) {
        guard let toAddress = addressTextField.text, let amount = amountTextField.text else {
            // TODO: tip in ui
            print("Invalid Entry")
            return
        }
        guard let gethAmount = GethBigInt.bigInt(amount) else {
            // TODO: tip in ui
            print("Invalid amount")
            return
        }
        if let token = TokenDataManager.shared.getTokenBySymbol(asset!.symbol) {
            if !token.protocol_value.isHexAddress() {
                print("token protocol \(token.protocol_value) is invalid")
                return
            }
            if !toAddress.isHexAddress() {
                print("address \(toAddress) is invalide")
                return
            }
            var error: NSError? = nil
            let toAddress = GethNewAddressFromHex(toAddress, &error)!
            let contractAddress = GethNewAddressFromHex(token.protocol_value, &error)!
            _transfer(contractAddress: contractAddress, toAddress: toAddress, amount: gethAmount)

        } else {
            // TODO: tip in ui
            print("Invalid asset or token")
            return
        }
    }
    
    @objc func pressedMaxButton(_ sender: Any) {
        print("pressedMaxButton")
        amountTextField.text = asset?.balance
        amountInfoLabel.text = "$ \((asset?.display.description)!)"
    }

    @objc func sliderValueDidChange(_ sender: UISlider!) {
        print("Slider value changed")
        let step: Float = 10
        let roundedStepValue = round(sender.value / step) * step
        
        // Get value from Replay API.
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        
        return true
    }
    
    func getActiveTextField() -> UITextField? {
        return nil
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        if #available(iOS 11.0, *) {
            // Get the the distance from the bottom safe area edge to the bottom of the screen
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            scrollViewButtonLayoutConstraint.constant = keyboardHeight + 77
            sendButtonLayoutContraint.constant = keyboardHeight + 15 - bottomPadding!
            
        } else {
            sendButtonLayoutContraint.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        print("keyboardWillDisappear")
        scrollViewButtonLayoutConstraint.constant = 77
        sendButtonLayoutContraint.constant = 15
    }

    func showKeyboard(textField: UITextField) {
        
    }
    
    func hideKeyboard() {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll \(scrollView.contentOffset.y)")
        if tokenTotalAmountLabel.frame.maxY < scrollView.contentOffset.y {
            self.navigationItem.title = asset!.symbol
        } else {
            self.navigationItem.title = ""
        }
    }
}

extension SendAssetViewController {

    var gasLimit: Int64 {
        var type = "token_transfer"
        if let asset = self.asset {
            if asset.symbol.uppercased() == "ETH" {
                type = "eth_transfer"
            }
        }
        return SendCurrentAppWalletDataManager.shared.getGasLimitByType(type: type)!
    }
    
    var gasPrice: Int64 {
        // TODO: get value from transactionSpeedSlider
        return 20000000000
    }

    func getNonce() -> Int64 {
        return SendCurrentAppWalletDataManager.shared.getNonce()
    }

    func executeContract(_ signedTransaction: String) {
        SendCurrentAppWalletDataManager.shared.sendTransactionToServer(signedTransaction) { (txHash, error) in
            guard error == nil && txHash != nil else {
                // TODO
                print("Failed to get valid response from server: \(error!)")

                // Show toast
                DispatchQueue.main.async {
                    let myString = NSLocalizedString("Insufficient funds for gas x price + value", comment: "")
                    let myAttribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
                    let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
                    let banner = NotificationBanner(attributedTitle: myAttrString, style: .danger)
                    banner.duration = 1.0
                    banner.show()
                }

                return
            }
            print("Result of transfer is \(txHash!)")
        }
    }

    func _transfer(contractAddress: GethAddress, toAddress: GethAddress, amount: GethBigInt) {
        
        // let _keystore = _createKeystore(configuration.namespace)

        // TODO: Have to create a wallet using EthAccountCoordinator. It will be used in web3swift.sign()
        let configuration = EthAccountConfiguration(namespace: "wallet", password: "password")
        let (_, _) = EthAccountCoordinator.default.launch(configuration)
        
        let transferFunction = EthFunction(name: "transfer", inputParameters: [toAddress, amount])
        let encodedTransferFunction = web3swift.encode(transferFunction) // ok here

        do {
            let nonce: Int64 = getNonce()
            let signedTransaction = web3swift.sign(address: contractAddress, encodedFunctionData: encodedTransferFunction, nonce: nonce, gasLimit: GethNewBigInt(gasLimit), gasPrice: GethNewBigInt(gasPrice))
            if let signedTransactionData = try signedTransaction?.encodeRLP() { // also ok here
                
                let  a = "0x"+signedTransactionData.hexString
                print(a)
                
                executeContract(a)
            } else {
                print("Failed to sign/encode")
            }
        } catch {
            print("Failed in encoding transaction ")
        }
    }
}
