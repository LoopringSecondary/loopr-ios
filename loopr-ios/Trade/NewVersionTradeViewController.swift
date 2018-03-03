//
//  NewVersionTradeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class NewVersionTradeViewController: UIViewController {

    // TODO: Not use system tintColor.
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceUnitLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountUnitLabel: UILabel!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var totalUnitLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineToBuyBtn: NSLayoutConstraint!
    @IBOutlet weak var underlineToSellBtn: NSLayoutConstraint!
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    
    @IBOutlet weak var keyboard: DefaultNumericKeyboard!
    
    @IBAction func pressBuyButton(_ sender: UIButton) {
        updateLayoutForUnderline(underlineToSellBtn, underlineToBuyBtn)
    }
    
    @IBAction func pressSellButton(_ sender: UIButton) {
        
        updateLayoutForUnderline(underlineToBuyBtn, underlineToSellBtn)
    }
    
    // TODO: Use SwipeViewController. Buy and Sell are complicated UI. It's better to hold them as two seperate view controller.
    func updateLayoutForUnderline(_ originConstraint: NSLayoutConstraint, _ currentConstraint: NSLayoutConstraint) {
        
        originConstraint.priority = .defaultLow
        currentConstraint.priority = .defaultHigh
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func pressedExpiresButton(_ sender: UIButton) {
        
        let buttonArray = [hourButton, dayButton, weekButton, monthButton]
        buttonArray.forEach {
            $0?.isSelected = false
            $0?.borderColor = UIColor.groupTableViewBackground
            $0?.backgroundColor = UIColor.clear
        }
        sender.isSelected = true
        sender.borderColor = sender.tintColor
        sender.backgroundColor = sender.tintColor
    }
    
    @IBAction func pressCloseButton(_ sender: UIBarButtonItem) {

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedContinueButton(_ sender: UIButton) {
        
        let vc = TradePlaceOrderViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.navigationItem.title = "LRC/WETH"
        
        keyboard.delegate = self
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        
        priceTextField.setRightPaddingPoints(priceUnitLabel.frame.size.width + 8)
        amountTextField.setRightPaddingPoints(amountUnitLabel.frame.size.width + 2)
        totalTextField.setRightPaddingPoints(totalUnitLabel.frame.size.width + 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NewVersionTradeViewController: NumericKeyboardDelegate {
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        
        switch (position.row, position.column) {
        default:
            return
        }
    }
}

extension UITextField {
    
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
