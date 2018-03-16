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
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Received"
        
        view.theme_backgroundColor = ["#fff", "#000"]
        typeImageView.theme_image = ["Received", "Received-white"]
        amountLabel.theme_textColor = ["#000", "#fff"]
        amountInCurrencyLabel.theme_textColor = ["#000", "#fff"]
        label1.theme_textColor = ["#000", "#fff"]
        label2.theme_textColor = ["#000", "#fff"]
        label3.theme_textColor = ["#000", "#fff"]
        label4.theme_textColor = ["#000", "#fff"]
        label5.theme_textColor = ["#000", "#fff"]
        label6.theme_textColor = ["#000", "#fff"]
        label7.theme_textColor = ["#000", "#fff"]
        label8.theme_textColor = ["#000", "#fff"]

        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let line1 = DashedLineView(frame: CGRect(x: label1.frame.origin.x, y: label1.frame.origin.y + label1.frame.size.height * 0.5, width: self.view.frame.size.width - label1.frame.origin.x * 2, height: 1))
        line1.lineColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        self.view.addSubview(line1)

        let line2 = DashedLineView(frame: CGRect(x: label3.frame.origin.x, y: label3.frame.origin.y + label3.frame.size.height * 0.5, width: self.view.frame.size.width - label3.frame.origin.x * 2, height: 1))
        line2.lineColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        self.view.addSubview(line2)
        
        let line3 = DashedLineView(frame: CGRect(x: label5.frame.origin.x, y: label5.frame.origin.y + label5.frame.size.height * 0.5, width: self.view.frame.size.width - label5.frame.origin.x * 2, height: 1))
        line3.lineColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        self.view.addSubview(line3)
        
        let line4 = DashedLineView(frame: CGRect(x: label7.frame.origin.x, y: label7.frame.origin.y + label7.frame.size.height * 0.5, width: self.view.frame.size.width - label7.frame.origin.x * 2, height: 1))
        line4.lineColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        self.view.addSubview(line4)
        update()
    }
    
    func update() {
        if let transaction = transaction {
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
