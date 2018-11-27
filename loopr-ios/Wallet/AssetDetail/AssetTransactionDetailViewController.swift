//
//  AssetTransactionDetailViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/24/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Social

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
    @IBOutlet weak var gasContainerView: UIView!
    @IBOutlet weak var gasTipLabel: UILabel!
    @IBOutlet weak var gasInfoLabel: UILabel!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dateTipLabel: UILabel!
    @IBOutlet weak var dateInfoLabel: UILabel!
    @IBOutlet weak var shareContainerView: UIView!
    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var cellBackgroundView: UIView!
    
    var transaction: Transaction?
    var dismissClosure: (() -> Void)?
    var parentNavController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        containerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        setBackButton()
        
        closeButton.theme_setImage(GlobalPicker.close, forState: .normal)
        closeButton.theme_setImage(GlobalPicker.closeHighlight, forState: .highlighted)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        typeContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        statusContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        toContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        idContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        gasContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        dateContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        shareContainerView.theme_backgroundColor = ColorPicker.cardBackgroundColor

        cellBackgroundView.theme_backgroundColor = ColorPicker.cardHighLightColor
        
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
        titleLabel.theme_textColor = GlobalPicker.textColor
        titleLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        titleLabel.text = LocalizedString("Transaction Detail", comment: "")
        
        // Row 1
        typeTipLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        typeTipLabel.theme_textColor = GlobalPicker.textLightColor

        typeInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        typeInfoLabel.theme_textColor = GlobalPicker.textColor
        
        // Row 2
        statusTipLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        statusTipLabel.theme_textColor = GlobalPicker.textLightColor
        statusTipLabel.text = LocalizedString("Status", comment: "")
        
        statusInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        statusInfoLabel.theme_textColor = GlobalPicker.textColor
        
        // Row 3
        toTipLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        toTipLabel.theme_textColor = GlobalPicker.textLightColor
        toTipLabel.text = LocalizedString("Address", comment: "")
        toInfoButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 14)
        
        // Row 4
        idTipLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        idTipLabel.theme_textColor = GlobalPicker.textLightColor
        idTipLabel.text = LocalizedString("TxHash", comment: "")
        idInfoButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 14)
        
        // Row 5
        gasTipLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        gasTipLabel.theme_textColor = GlobalPicker.textLightColor
        gasTipLabel.text = LocalizedString("Gas", comment: "")
        
        gasInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        gasInfoLabel.theme_textColor = GlobalPicker.textColor
        
        // Row 6
        dateTipLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        dateTipLabel.theme_textColor = GlobalPicker.textLightColor
        dateTipLabel.text = LocalizedString("Date", comment: "")
        
        dateInfoLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        dateInfoLabel.theme_textColor = GlobalPicker.textColor
        
        // Row 7
        shareButton.titleLabel?.font = FontConfigManager.shared.getRegularFont(size: 14)
        shareButton.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        shareButton.theme_setTitleColor(GlobalPicker.textLightColor, forState: .highlighted)
        shareButton.title = LocalizedString("Share", comment: "")
        shareButton.addTarget(self, action: #selector(pressedShareButton(_:)), for: UIControlEvents.touchUpInside)
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
        typeTipLabel.text = LocalizedString("Cancel Order", comment: "")
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
        let total = tx.gasPriceInGWei * tx.gasUsed / 1000000000
        let currency = PriceDataManager.shared.getPrice(of: "ETH", by: total)
        gasInfoLabel.text = "\(total.withCommas(6)) ETH ≈ \(currency!)"
    }
    
    @IBAction func pressedToButton(_ sender: UIButton) {
        self.close()
        var etherUrl = "https://etherscan.io/address/"
        if let tx = self.transaction {
            if tx.type == .received {
                etherUrl += tx.from
            } else {
                etherUrl += tx.to
            }
            if let url = URL(string: etherUrl) {
                let viewController = DefaultWebViewController()
                viewController.navigationTitle = "Etherscan.io"
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
    
    @objc func pressedShareButton(_ sender: UIButton) {
        var etherUrl = "https://etherscan.io/tx/"
        if let tx = self.transaction {
            etherUrl += tx.txHash
            if let url = URL(string: etherUrl) {
                let text = url.absoluteString
                let shareAll = [text] as [Any]
                let activityVC = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
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
