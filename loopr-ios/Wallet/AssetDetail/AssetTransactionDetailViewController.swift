//
//  AssetTransactionDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTransactionDetailViewController: UIViewController {

    var transaction: Transaction?
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountInCurrencyLabel: UILabel!
    
    // Different types may have different info to show.
    // Row 1
    var label1 = UILabel()
    var label2 = UILabel()
    var row1Underline = UIView()
    
    // Row 2
    var label3 = UILabel()
    var label4 = UILabel()
    var row2Underline = UIView()
    
    // Row 3
    var label5 = UILabel()
    var label6 = UILabel()
    var row3Underline = UIView()
    
    // Row 4
    var label7 = UILabel()
    var label8 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Details", comment: "")
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        view.theme_backgroundColor = ["#fff", "#000"]
        typeImageView.theme_image = ["Received", "Received-white"]
        amountLabel.theme_textColor = ["#000", "#fff"]
        amountInCurrencyLabel.theme_textColor = ["#000", "#fff"]
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        let originY: CGFloat = screenHeight * 0.5
        let padding: CGFloat = 15
        let labelHeight: CGFloat = 40
        
        // Row 1
        label1.text = "Status"
        label1.theme_textColor = GlobalPicker.textColor
        label1.font = FontConfigManager.shared.getLabelFont(size: 14)
        label1.frame = CGRect(x: padding, y: originY, width: 80, height: labelHeight)
        view.addSubview(label1)
        
        label2.theme_textColor = GlobalPicker.textColor
        label2.textAlignment = .right
        label2.font = FontConfigManager.shared.getLabelFont(size: 14)
        label2.frame = CGRect(x: padding + 80 - 40, y: originY, width: screenWidth-80-2*padding + 40, height: labelHeight)
        view.addSubview(label2)
        
        row1Underline.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        row1Underline.frame = CGRect(x: padding, y: label1.frame.maxY, width: screenWidth - 2*padding, height: 0.5)
        view.addSubview(row1Underline)

        // Row 2
        label3.text = "From"
        label3.theme_textColor = GlobalPicker.textColor
        label3.font = FontConfigManager.shared.getLabelFont(size: 14)
        label3.frame = CGRect(x: padding, y: row1Underline.frame.maxY + padding, width: 80, height: labelHeight)
        view.addSubview(label3)
        
        label4.theme_textColor = GlobalPicker.textColor
        label4.textAlignment = .right
        label4.font = FontConfigManager.shared.getLabelFont(size: 14)
        // label 4 may
        label4.frame = CGRect(x: padding + 80, y: row1Underline.frame.maxY + padding, width: screenWidth-80-2*padding, height: labelHeight)
        view.addSubview(label4)

        row2Underline.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        row2Underline.frame = CGRect(x: padding, y: label3.frame.maxY, width: screenWidth - 2*padding, height: 0.5)
        view.addSubview(row2Underline)
        
        // Row 3
        label5.text = "ID"
        label5.theme_textColor = GlobalPicker.textColor
        label5.font = FontConfigManager.shared.getLabelFont(size: 14)
        label5.frame = CGRect(x: padding, y: row2Underline.frame.maxY + padding, width: 80, height: labelHeight)
        view.addSubview(label5)
        
        label6.theme_textColor = GlobalPicker.textColor
        label6.textAlignment = .right
        label6.font = FontConfigManager.shared.getLabelFont(size: 14)
        label6.frame = CGRect(x: padding + 80, y: row2Underline.frame.maxY + padding, width: screenWidth-80-2*padding, height: labelHeight)
        view.addSubview(label6)

        row3Underline.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        row3Underline.frame = CGRect(x: padding, y: label5.frame.maxY, width: screenWidth - 2*padding, height: 0.5)
        view.addSubview(row3Underline)

        // Row 4
        label7.text = "Date"
        label7.theme_textColor = GlobalPicker.textColor
        label7.font = FontConfigManager.shared.getLabelFont(size: 14)
        label7.frame = CGRect(x: padding, y: row3Underline.frame.maxY + padding, width: 80, height: labelHeight)
        view.addSubview(label7)
        
        label8.theme_textColor = GlobalPicker.textColor
        label8.textAlignment = .right
        label8.font = FontConfigManager.shared.getLabelFont(size: 14)
        label8.frame = CGRect(x: padding + 80, y: row3Underline.frame.maxY + padding, width: screenWidth-80-2*padding, height: labelHeight)
        view.addSubview(label8)

        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func update() {
        if let transaction = transaction {
            typeImageView.image = transaction.icon
            amountLabel.text = transaction.value + " " + transaction.symbol
            amountInCurrencyLabel.text = "≈ $\(transaction.display)"
            label2.text = transaction.status.description
            // TODO: cover all cases
            switch transaction.type {
            case .received:
                label3.text = "From"
                label4.text = transaction.from
            case .sent:
                label3.text = "To"
                label4.text = transaction.to
            default:
                label3.text = transaction.type.description
                label4.text = transaction.status.description
            }
            label6.text = transaction.txHash
            label8.text = transaction.updateTime
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
