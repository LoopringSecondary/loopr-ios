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
        self.title = "Received"
        
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
        
        let originY: CGFloat = screenHeight * 0.4
        let padding: CGFloat = 15
        
        label1.theme_textColor = GlobalPicker.textColor
        label1.font = FontConfigManager.shared.getLabelFont()
        label1.backgroundColor = UIColor.blue
        label1.frame = CGRect(x: padding, y: originY, width: 80, height: 40)
        view.addSubview(label1)
        
        label2.theme_textColor = GlobalPicker.textColor
        label2.font = FontConfigManager.shared.getLabelFont()
        label2.backgroundColor = UIColor.blue
        label2.frame = CGRect(x: padding + 80, y: originY, width: screenWidth-80-2*padding, height: 40)
        view.addSubview(label2)
        
        row1Underline.theme_backgroundColor = GlobalPicker.backgroundColor
        row1Underline.frame = CGRect(x: padding, y: label1.frame.maxY, width: screenWidth - 2*padding, height: 1)
        view.addSubview(row1Underline)

        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func update() {
        if let transaction = transaction {
            print(transaction.from)

            typeImageView.image = transaction.icon
            amountLabel.text = transaction.value + " " + transaction.symbol
            amountInCurrencyLabel.text = "≈ $\(transaction.display)"
            switch transaction.type {
            case .received:
                label1.text = "From"
                label2.text = transaction.from
            case .sent:
                label1.text = "To"
                label2.text = transaction.to
            default:
                label1.text = transaction.type.description
                label2.text = ""
            }
            label4.text = transaction.txHash
            label6.text = transaction.createTime
            label8.text = transaction.status.description
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
