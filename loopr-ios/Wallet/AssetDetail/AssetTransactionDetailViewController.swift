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
    
    @IBOutlet weak var titleLabel: UILabel!
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
    var button1 = UIButton()
    var row2Underline = UIView()
    
    // Row 3
    var label5 = UILabel()
    var button2 = UIButton()
    var row3Underline = UIView()
    
    // Row 4
    var label7 = UILabel()
    var label8 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Details", comment: "")
        
        setBackButton()
        
        view.theme_backgroundColor = ["#fff", "#000"]
        typeImageView.theme_image = ["Received", "Received-white"]
        
        // setup label
        if let transaction = self.transaction {
            setupLabel(transaction: transaction)
        }
        amountLabel.theme_textColor = ["#000", "#fff"]
        
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
        
        button1.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        button1.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        button1.titleLabel?.font = FontConfigManager.shared.getLabelFont(size: 14)
        button1.contentHorizontalAlignment = .right
        button1.frame = CGRect(x: padding + 80, y: row1Underline.frame.maxY + padding, width: screenWidth - 80 - 2 * padding, height: labelHeight)
        button1.addTarget(self, action: #selector(self.pressedButton1(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(button1)
        
        row2Underline.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        row2Underline.frame = CGRect(x: padding, y: label3.frame.maxY, width: screenWidth - 2*padding, height: 0.5)
        view.addSubview(row2Underline)
        
        // Row 3
        label5.text = "ID"
        label5.theme_textColor = GlobalPicker.textColor
        label5.font = FontConfigManager.shared.getLabelFont(size: 14)
        label5.frame = CGRect(x: padding, y: row2Underline.frame.maxY + padding, width: 80, height: labelHeight)
        view.addSubview(label5)
        
        button2.theme_setTitleColor(["#0094FF", "#000"], forState: .normal)
        button2.setTitleColor(UIColor.init(rgba: "#cce9ff"), for: .highlighted)
        button2.titleLabel?.font = FontConfigManager.shared.getLabelFont(size: 14)
        button2.contentHorizontalAlignment = .right
        button2.frame = CGRect(x: padding + 80, y: row2Underline.frame.maxY + padding, width: screenWidth-80-2*padding, height: labelHeight)
        button2.addTarget(self, action: #selector(self.pressedButton2(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(button2)

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
    
    func setupLabel(transaction: Transaction) {
        titleLabel.text = "You \(transaction.type.description)"
        titleLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 30)
        titleLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        amountLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 40)
        
        amountLabel.textColor = Themes.isNight() ? UIColor.white : UIColor.black
        amountInCurrencyLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 20)
        amountInCurrencyLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }
    
    @objc func pressedButton1(_ sender: Any) {
        var etherUrl = "https://etherscan.io/address/"
        if let tx = self.transaction {
            if tx.type == .sent {
                etherUrl += tx.to
            } else if tx.type == .received {
                etherUrl += tx.from
            }
            if let url = URL(string: etherUrl) {
                let viewController = AssetTransactionWebViewController()
                viewController.url = url
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func pressedButton2(_ sender: Any) {
        var etherUrl = "https://etherscan.io/tx/"
        if let tx = self.transaction {
            etherUrl += tx.txHash
            if let url = URL(string: etherUrl) {
                let viewController = AssetTransactionWebViewController()
                viewController.url = url
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func update() {
        if let transaction = transaction {
            typeImageView.image = transaction.icon
            amountLabel.text = transaction.value + " " + transaction.symbol
            amountInCurrencyLabel.text = "≈ \(transaction.display)"
            label2.text = transaction.status.description
            // TODO: cover all cases
            switch transaction.type {
            case .received:
                label3.text = "From"
                button1.title = transaction.from
            case .sent:
                label3.text = "To"
                button1.title = transaction.to
            case .approved:
                amountLabel.isHidden = true
                amountInCurrencyLabel.isHidden = true
                label3.text = transaction.type.description
                button1.title = transaction.status.description
                button1.titleColor = UIColor.black
            default:
                label3.text = transaction.type.description
                button1.title = transaction.status.description
                button1.titleColor = UIColor.black
            }
            button2.title = transaction.txHash
            label8.text = transaction.updateTime
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
