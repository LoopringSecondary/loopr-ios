//
//  AssetTransactionDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTransactionDetailViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeContainerView: UIView!
    @IBOutlet weak var typeTipLabel: UILabel!
    @IBOutlet weak var typeInfoLabel: UILabel!
    @IBOutlet weak var statusContainerView: UIView!
    @IBOutlet weak var statusTipLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var toContainerView: UIView!
    @IBOutlet weak var toTipLabel: UILabel!
    @IBOutlet weak var toInfoButton: UIButton!
    @IBOutlet weak var idContainerView: UIView!
    @IBOutlet weak var idTipLabel: UILabel!
    @IBOutlet weak var idInfoButton: UIButton!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dateTipLabel: UILabel!
    @IBOutlet weak var dateInfoLabel: UILabel!
    
    var transaction: Transaction?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setBackButton()
        
        view.theme_backgroundColor = ["#fff", "#000"]
        containerView.theme_backgroundColor = GlobalPicker.cardHighLightColor
        typeContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        statusContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        toContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        idContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        dateContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        // setup label
        if let transaction = self.transaction {
            setupLabels(transaction: transaction)
        }
        update()
    }
    
    func setupLabels(transaction: Transaction) {
        titleLabel.text = LocalizedString("Details", comment: "")
        titleLabel.font = FontConfigManager.shared.getCharactorFont(size: 20)
        titleLabel.theme_textColor = ["#000000cc", "#ffffffcc"]
        typeTipLabel.setTitleCharFont()
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        toTipLabel.setTitleCharFont()
        idTipLabel.setTitleCharFont()
        idTipLabel.text = LocalizedString("ID", comment: "")
        dateTipLabel.setTitleCharFont()
        dateTipLabel.text = LocalizedString("Date", comment: "")
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
                let viewController = DefaultWebViewController()
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
                let viewController = DefaultWebViewController()
                viewController.navigationTitle = "Etherscan.io"
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
//        if let transaction = transaction {
//            if let image = UIImage(named: "Transaction-\(transaction.type.rawValue)") {
//                typeImageView.image = image
//            }
//            amountLabel.text = transaction.value + " " + transaction.symbol
//            amountInCurrencyLabel.text = "≈ \(transaction.currency)"
//            label2.text = transaction.status.description
//            // TODO: cover all cases
//            switch transaction.type {
//            case .received:
//                label3.text = LocalizedString("From", comment: "")
//                button1.title = transaction.from
//            case .sent:
//                label3.text = LocalizedString("To", comment: "")
//                button1.title = transaction.to
//            case .approved:
//                amountLabel.isHidden = true
//                amountInCurrencyLabel.isHidden = true
//                label3.text = transaction.type.description
//                button1.title = transaction.status.description
//                button1.titleColor = UIColor.black
//            default:
//                label3.text = transaction.type.description
//                button1.title = transaction.status.description
//                button1.titleColor = UIColor.black
//            }
//            button2.title = transaction.txHash
//            label8.text = transaction.updateTime
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
