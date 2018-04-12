//
//  OrderDetailViewController.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/12.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController {
    
    @IBOutlet weak var marketLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var filledPieChart: CircleChart!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    
    var order: Order?
    
    // Amount
    var amountTipLabel: UILabel = UILabel()
    var amountInfoLabel: UILabel = UILabel()
    var amountUnderline: UIView = UIView()
    // Status
    var statusTipLabel: UILabel = UILabel()
    var statusInfoLabel: UILabel = UILabel()
    var statusUnderline: UIView = UIView()
    // Total
    var totalTipLabel: UILabel = UILabel()
    var totalInfoLabel: UILabel = UILabel()
    var totalUnderline: UIView = UIView()
    // Filled
    var filledTipLabel: UILabel = UILabel()
    var filledInfoLabel: UILabel = UILabel()
    var filledUnderline: UIView = UIView()
    // ID
    var idTipLabel: UILabel = UILabel()
    var idInfoLabel: UILabel = UILabel()
    var idUnderline: UIView = UIView()
    // Date
    var dateTipLabel: UILabel = UILabel()
    var dateInfoLabel: UILabel = UILabel()
    var dateUnderline: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        let padding: CGFloat = 15
        
        // First row: amount
        amountTipLabel.font = FontConfigManager.shared.getLabelFont()
        amountTipLabel.text = "Filled/Amount"
        amountTipLabel.frame = CGRect(x: padding, y: displayLabel.frame.maxY + padding * 3, width: screenWidth - padding * 2, height: 40)
        view.addSubview(amountTipLabel)
        amountInfoLabel.font = FontConfigManager.shared.getLabelFont()
        amountInfoLabel.text = "sdfsdf"
        amountInfoLabel.textAlignment = .right
        amountInfoLabel.frame = CGRect(x: screenWidth - padding - 80, y: amountTipLabel.frame.origin.y, width: 80, height: 40)
        view.addSubview(amountInfoLabel)
        amountUnderline.frame = CGRect(x: padding, y: amountInfoLabel.frame.maxY, width: screenWidth - padding * 2, height: 1)
        amountInfoLabel.backgroundColor = UIColor.black
        view.addSubview(amountUnderline)
        
//        addressInfoLabel.frame = CGRect(x: padding, y: addressUnderLine.frame.maxY, width: screenWidth - padding * 2, height: 40)
//        addressInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
//        addressInfoLabel.text = "Please confirm the address before sending."
//        scrollView.addSubview(addressInfoLabel)
//
//        // Third row: Amount
//
//        amountTextField.delegate = self
//        amountTextField.tag = 1
//        amountTextField.inputView = UIView()
//        amountTextField.font = FontConfigManager.shared.getLabelFont()
//        amountTextField.theme_tintColor = GlobalPicker.textColor
//        amountTextField.placeholder = "Enter the amount"
//        amountTextField.contentMode = UIViewContentMode.bottom
//        amountTextField.frame = CGRect(x: padding, y: addressInfoLabel.frame.maxY + padding*1.5, width: screenWidth-padding*2-80, height: 40)
//        scrollView.addSubview(amountTextField)
//
//        tokenSymbolLabel.font = FontConfigManager.shared.getLabelFont()
//        tokenSymbolLabel.textAlignment = .right
//        tokenSymbolLabel.frame = CGRect(x: screenWidth-padding-80, y: amountTextField.frame.origin.y, width: 80, height: 40)
//        scrollView.addSubview(tokenSymbolLabel)
//
//        amountUnderline.frame = CGRect(x: padding, y: amountTextField.frame.maxY, width: screenWidth - padding * 2, height: 1)
//        amountUnderline.backgroundColor = UIColor.black
//        scrollView.addSubview(amountUnderline)
//
//        amountInfoLabel.frame = CGRect(x: padding, y: amountUnderline.frame.maxY, width: screenWidth - padding * 2, height: 40)
//        amountInfoLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
//        amountInfoLabel.text = "$ 319,491.31"
//        scrollView.addSubview(amountInfoLabel)
//
//        maxButton.title = "Max"
//        maxButton.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
//        maxButton.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
//        maxButton.titleLabel?.font = FontConfigManager.shared.getLabelFont()
//        maxButton.contentHorizontalAlignment = .right
//        maxButton.frame = CGRect(x: screenWidth-80-padding, y: amountUnderline.frame.maxY, width: 80, height: 40)
//        maxButton.addTarget(self, action: #selector(self.pressedMaxButton(_:)), for: UIControlEvents.touchUpInside)
//        scrollView.addSubview(maxButton)
//
//        transactionFeeLabel.frame = CGRect(x: padding, y: maxButton.frame.maxY + padding*2, width: 120, height: 40)
//        transactionFeeLabel.font = FontConfigManager.shared.getLabelFont()
//        transactionFeeLabel.text = "Transaction Fee"
//        scrollView.addSubview(transactionFeeLabel)
//
//        transactionFeeAmountLabel.frame = CGRect(x: screenWidth-300-padding, y: maxButton.frame.maxY + padding*2, width: 300, height: 40)
//        transactionFeeAmountLabel.font = FontConfigManager.shared.getLabelFont()
//        transactionFeeAmountLabel.textAlignment = .right
//        transactionFeeAmountLabel.text = "1.232 LRC = $1.46"
//        scrollView.addSubview(transactionFeeAmountLabel)
//
//        // Fouth row: Advanced
//
//        advancedLabel.frame = CGRect(x: padding, y: transactionFeeAmountLabel.frame.maxY + padding, width: 120, height: 40)
//        advancedLabel.font = FontConfigManager.shared.getLabelFont()
//        advancedLabel.text = "Advanced"
//        scrollView.addSubview(advancedLabel)
//
//        transactionSpeedSlider.frame = CGRect(x: padding, y: advancedLabel.frame.maxY + padding*0.5, width: screenWidth-2*padding, height: 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
