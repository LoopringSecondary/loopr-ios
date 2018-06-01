//
//  AssetTransactionTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTransactionTableViewCell: UITableViewCell {

    var transaction: Transaction?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var seperateLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.setTitleFont()
        amountLabel.setTitleFont()
        amountLabel.baselineAdjustment = .alignCenters
        dateLabel.setSubTitleFont()
        displayLabel.setSubTitleFont()
        displayLabel.baselineAdjustment = .alignCenters
        typeImageView.theme_image = ["Received", "Received-white"]
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let transaction = transaction {
            typeImageView.image = transaction.icon
            dateLabel.text = transaction.createTime
            switch transaction.type {
            case .convert_income:
                updateConvertIncome()
            case .convert_outcome:
                updateConvertOutcome()
            case .approved:
                updateApprove()
            case .cutoff, .canceledOrder:
                udpateCutoffAndCanceledOrder()
            default:
                updateDefault()
            }
        }
    }
    
    private func updateConvertIncome() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        if transaction!.symbol.lowercased() == "weth" {
            titleLabel.text = NSLocalizedString("Convert ETH To WETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel.text = NSLocalizedString("Convert WETH To ETH", comment: "")
        }
        amountLabel.text = "\(transaction!.value) \(transaction?.symbol ?? " ")"
        displayLabel.text = transaction!.display
    }
    
    private func updateConvertOutcome() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        if transaction!.symbol.lowercased() == "weth" {
            titleLabel!.text = NSLocalizedString("Convert WETH To ETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel!.text = NSLocalizedString("Convert ETH To WETH", comment: "")
        }
        amountLabel.text = "\(transaction!.value) \(transaction?.symbol ?? " ")"
        displayLabel.text = transaction!.display
    }
    
    private func updateApprove() {
        amountLabel.isHidden = true
        displayLabel.isHidden = true
        titleLabel.text = NSLocalizedString("Enable \(transaction!.symbol) To Trade", comment: "")
    }
    
    private func udpateCutoffAndCanceledOrder() {
        amountLabel.isHidden = true
        displayLabel.isHidden = true
        titleLabel.text = NSLocalizedString("Cancel Order(s)", comment: "")
    }
    
    private func updateDefault() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        titleLabel.text = transaction!.type.description + " " + transaction!.symbol
        amountLabel.text = "\(transaction!.value) \(transaction?.symbol ?? " ")"
        displayLabel.text = transaction!.display
    }

    class func getCellIdentifier() -> String {
        return "AssetTransactionTableViewCell"
    }

    class func getHeight() -> CGFloat {
        return 84
    }
}
