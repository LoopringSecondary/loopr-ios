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
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        titleLabel.theme_textColor = GlobalPicker.textColor
        amountLabel.theme_textColor = GlobalPicker.textColor
        dateLabel.theme_textColor = ["#a0a0a0", "#fff"]
        displayLabel.theme_textColor = ["#a0a0a0", "#fff"]
        typeImageView.theme_image = ["Received", "Received-white"]
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
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
                if transaction.symbol.lowercased() == "weth" {
                    titleLabel.text = NSLocalizedString("Convert ETH To WETH", comment: "")
                } else if transaction.symbol.lowercased() == "eth" {
                    titleLabel.text = NSLocalizedString("Convert WETH To ETH", comment: "")
                }
                amountLabel.text = transaction.value
                displayLabel.text = transaction.display
            case .convert_outcome:
                if transaction.symbol.lowercased() == "weth" {
                    titleLabel.text = NSLocalizedString("Convert ETH To WETH", comment: "")
                } else if transaction.symbol.lowercased() == "eth" {
                    titleLabel.text = NSLocalizedString("Convert ETH To WETH", comment: "")
                }
                amountLabel.text = transaction.value
                displayLabel.text = transaction.display
            case .approved:
                titleLabel.text = NSLocalizedString("Enable \(transaction.symbol) To Trade", comment: "")
                amountLabel.isHidden = true
                displayLabel.isHidden = true
            case .cutoff, .canceledOrder:
                titleLabel.text = NSLocalizedString("Cancel Order(s)", comment: "")
                amountLabel.isHidden = true
                displayLabel.isHidden = true
            default:
                titleLabel.text = transaction.type.description + " " + transaction.symbol
                amountLabel.text = transaction.value
                displayLabel.text = transaction.display
            }
        }
    }

    class func getCellIdentifier() -> String {
        return "AssetTransactionTableViewCell"
    }

    class func getHeight() -> CGFloat {
        return 84
    }

}
