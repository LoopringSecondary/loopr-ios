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
    @IBOutlet weak var closeButton: UIButton!
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
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modalPresentationStyle = .custom
        
        setBackButton()
        
        view.theme_backgroundColor = ["#fff", "#000"]
        closeButton.theme_setImage(GlobalPicker.close, forState: .normal)
        closeButton.theme_setImage(GlobalPicker.closeHighlight, forState: .highlighted)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        containerView.theme_backgroundColor = GlobalPicker.cardHighLightColor
        typeContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        statusContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        toContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        idContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        dateContainerView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        // setup label
        setupLabels()
        if let transaction = self.transaction {
            update(transaction: transaction)
        }
    }
    
    func setupLabels() {
        titleLabel.setTitleCharFont()
        titleLabel.text = LocalizedString("Transaction Detail", comment: "")
        typeTipLabel.setTitleCharFont()
        typeInfoLabel.setTitleCharFont()
        statusTipLabel.setTitleCharFont()
        statusTipLabel.text = LocalizedString("Status", comment: "")
        statusInfoLabel.setTitleCharFont()
        toTipLabel.setTitleCharFont()
        toTipLabel.text = LocalizedString("Address", comment: "")
        toInfoButton.titleLabel?.setTitleCharFont()
        idTipLabel.setTitleCharFont()
        idTipLabel.text = LocalizedString("ID", comment: "")
        idInfoButton.titleLabel?.setTitleCharFont()
        dateTipLabel.setTitleCharFont()
        dateTipLabel.text = LocalizedString("Date", comment: "")
        dateInfoLabel.setTitleCharFont()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(transaction: Transaction) {
        switch transaction.type {
        case .convert_income:
            updateConvertIncome(tx: transaction)
        case .convert_outcome:
            updateConvertOutcome(tx: transaction)
        case .approved:
            updateApprove(tx: transaction)
        case .cutoff, .canceledOrder:
            udpateCutoffAndCanceledOrder()
        default:
            updateDefault(tx: transaction)
        }
        updateLabels(tx: transaction)
    }
    
    private func updateConvertIncome(tx: Transaction) {
        if tx.symbol.lowercased() == "weth" {
            typeTipLabel.text = LocalizedString("Convert to WETH", comment: "")
        } else if tx.symbol.lowercased() == "eth" {
            typeTipLabel.text = LocalizedString("Convert to ETH", comment: "")
        }
        typeInfoLabel.isHidden = false
        typeInfoLabel.textColor = UIColor.up
        typeInfoLabel.text = "+\(tx.value) \(tx.symbol) ≈ \(tx.currency)"
    }
    
    private func updateConvertOutcome(tx: Transaction) {
        if tx.symbol.lowercased() == "weth" {
            typeTipLabel.text = LocalizedString("Convert to ETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            typeTipLabel.text = LocalizedString("Convert to WETH", comment: "")
        }
        typeInfoLabel.isHidden = false
        typeInfoLabel.textColor = UIColor.down
        typeInfoLabel.text = "-\(tx.value) \(tx.symbol) ≈ \(tx.currency)"
    }
    
    private func updateApprove(tx: Transaction) {
        typeInfoLabel.isHidden = true
        typeTipLabel.textAlignment = .center
        let header = LocalizedString("Enabled", comment: "")
        let footer = LocalizedString("to Trade", comment: "")
        typeTipLabel.text = "\(header) \(transaction!.symbol) \(footer)"
    }
    
    private func udpateCutoffAndCanceledOrder() {
        typeInfoLabel.isHidden = true
        typeTipLabel.textAlignment = .center
        typeTipLabel.text = LocalizedString("Cancel Order(s)", comment: "")
    }
    
    private func updateDefault(tx: Transaction) {
        typeTipLabel.text = tx.type.description
        typeInfoLabel.isHidden = false
        if tx.type == .bought || tx.type == .received {
            typeInfoLabel.textColor = UIColor.up
            typeInfoLabel.text = "+\(tx.value) \(tx.symbol) ≈ \(tx.currency)"
            toInfoButton.title = tx.from
        } else if tx.type == .sold || tx.type == .sent {
            typeInfoLabel.textColor = UIColor.down
            typeInfoLabel.text = "-\(tx.value) \(tx.symbol) ≈ \(tx.currency)"
        }
    }
    
    func updateLabels(tx: Transaction) {
        switch tx.status {
        case .success:
            statusInfoLabel.textColor = .success
        case .failed:
            statusInfoLabel.textColor = .fail
        case .pending:
            statusInfoLabel.textColor = .warn
        case .other:
            statusInfoLabel.textColor = .text1
        }
        statusInfoLabel.text = tx.status.description
        toInfoButton.title = tx.to
        idInfoButton.title = tx.txHash
        dateInfoLabel.text = tx.createTime
    }
    
    @IBAction func pressedToButton(_ sender: UIButton) {
        self.close()
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
                self.parentNavController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func pressedIdButton(_ sender: UIButton) {
        self.close()
        var etherUrl = "https://etherscan.io/tx/"
        if let tx = self.transaction {
            etherUrl += tx.txHash
            if let url = URL(string: etherUrl) {
                let viewController = DefaultWebViewController()
                viewController.navigationTitle = "Etherscan.io"
                viewController.url = url
                viewController.hidesBottomBarWhenPushed = true
                self.parentNavController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func close() {
        if let closure = self.dismissClosure {
            closure()
        }
        self.dismiss(animated: true, completion: {
        })
    }
    
    @IBAction func pressedCloseButton(_ sender: UIButton) {
        self.close()
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        if containerView.frame.contains(location) {
            return false
        }
        return true
    }
}
