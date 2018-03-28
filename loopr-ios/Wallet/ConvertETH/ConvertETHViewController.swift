//
//  ConvertETHViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class ConvertETHViewController: UIViewController, UITextFieldDelegate, NumericKeyboardDelegate, NumericKeyboardProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewButtonLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var convertBackgroundView: UIView!

    var infoLabel: UILabel = UILabel()

    var tokenSView: TradeTokenView!
    var tokenBView: TradeTokenView!
    var arrowRightImageView: UIImageView = UIImageView()

    // Amout
    var tokenBLabel: UILabel = UILabel()
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

        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

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
        
        arrowRightImageView = UIImageView(frame: CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY), size: CGSize(width: 32, height: 32)))
        arrowRightImageView.image = UIImage.init(named: "Arrow-right-black")
        scrollView.addSubview(arrowRightImageView)
        
        infoLabel.frame = CGRect(center: CGPoint(x: screenWidth/2, y: tokenBView.frame.minY + tokenBView.iconImageView.frame.midY - 45), size: CGSize(width: 200, height: 21))
        infoLabel.text = "1 ETH = 1WETH"
        infoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 16)
        infoLabel.textAlignment = .center
        scrollView.addSubview(infoLabel)

        // Row 2: Amount
        
        tokenBLabel.text = "ETH"
        tokenBLabel.font = FontConfigManager.shared.getLabelFont()
        tokenBLabel.textAlignment = .right
        tokenBLabel.frame = CGRect(x: screenWidth-80-padding, y: tokenSView.frame.maxY + padding, width: 80, height: 40)
        scrollView.addSubview(tokenBLabel)
        
        amountTextField.delegate = self
        amountTextField.tag = 1
        amountTextField.inputView = UIView()
        amountTextField.font = FontConfigManager.shared.getLabelFont() // UIFont.init(name: FontConfigManager.shared.getLight(), size: 24)
        amountTextField.theme_tintColor = GlobalPicker.textColor
        amountTextField.placeholder = "Amount"
        amountTextField.contentMode = UIViewContentMode.bottom
        amountTextField.frame = CGRect(x: padding, y: tokenSView.frame.maxY + padding, width: screenWidth-padding*2-80, height: 40)
        scrollView.addSubview(amountTextField)

        amountUnderLine.frame = CGRect(x: padding, y: tokenBLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
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

        ConvertDataManager.shared.setup()
        
        // TODO: Update availableLabel
        availableLabel.text = "Available \(ConvertDataManager.shared.getMaxAmount()) ETH"
        
        tokenSView.update(symbol: "ETH")
        tokenBView.update(symbol: "WETH")
    }
    
    @objc func pressedMaxButton(_ sender: Any) {
        print("pressedMaxButton")
        
        // Get the max value from ConvertDataManager
        amountTextField.text = String(ConvertDataManager.shared.getMaxAmount())
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
    
    @IBAction func pressedConvertButton(_ sender: Any) {
        print("pressedConvertButton")

        ConvertDataManager.shared.convert()

        // Show toast
        let myString = NSLocalizedString("Convert Successfully.", comment: "")
        let myAttribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        let banner = NotificationBanner(attributedTitle: myAttrString, style: .success)
        banner.duration = 1.0
        banner.show()
        
        // Reset the text field
        amountTextField.text = ""
        
        availableLabel.text = "Available \(ConvertDataManager.shared.getMaxAmount()) ETH"
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
