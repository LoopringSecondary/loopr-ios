//
//  UpdatedAssetTransactionTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class UpdatedAssetTransactionTableViewCell: UITableViewCell {

    var transaction: Transaction?
    var baseView: UIView = UIView()
    var typeImageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var dateLabel: UILabel = UILabel()
    var amountLabel: UILabel = UILabel()
    var displayLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        baseView.frame = CGRect.init(x: 10, y: 10, width: screenWidth - 10*2, height: UpdatedAssetTransactionTableViewCell.getHeight() - 10)
        baseView.cornerRadius = 8
        addSubview(baseView)
        
        typeImageView.frame = CGRect.init(x: 16, y: 26, width: 28, height: 28)
        typeImageView.contentMode = .scaleAspectFit
        baseView.addSubview(typeImageView)
        
        titleLabel.frame = CGRect.init(x: 64, y: 22-3, width: 200, height: 36)
        titleLabel.setTitleCharFont()
        titleLabel.text = "ETHETHETHETHETHETHETH"  // Prototype the label size. Will be updated very soon.
        titleLabel.sizeToFit()
        titleLabel.text = ""
        baseView.addSubview(titleLabel)
        
        dateLabel.frame = CGRect.init(x: titleLabel.frame.minX, y: 44, width: 200, height: 27)
        dateLabel.setSubTitleDigitFont()
        dateLabel.text = "ETHETHETHETHETHETHETH"
        dateLabel.sizeToFit()
        dateLabel.text = ""
        baseView.addSubview(dateLabel)
        
        amountLabel.frame = CGRect.init(x: baseView.frame.width - 16 - 200, y: titleLabel.frame.minY, width: 200, height: titleLabel.frame.size.height)
        amountLabel.setTitleDigitFont()
        amountLabel.textAlignment = .right
        baseView.addSubview(amountLabel)
        
        displayLabel.frame = CGRect.init(x: amountLabel.frame.minX, y: dateLabel.frame.minY, width: 200, height: dateLabel.frame.size.height)
        displayLabel.setSubTitleDigitFont()
        displayLabel.textAlignment = .right
        baseView.addSubview(displayLabel)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = GlobalPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        }
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
            titleLabel.text = LocalizedString("Convert to WETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel.text = LocalizedString("Convert to ETH", comment: "")
        }
        amountLabel.text = "+\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.up
        displayLabel.text = transaction!.currency
    }
    
    private func updateConvertOutcome() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        if transaction!.symbol.lowercased() == "weth" {
            titleLabel.text = LocalizedString("Convert to WETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel.text = LocalizedString("Convert to ETH", comment: "")
        }
        amountLabel.text = "-\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.down
        displayLabel.text = transaction!.currency
    }
    
    private func updateApprove() {
        amountLabel.isHidden = true
        displayLabel.isHidden = true
        let header = LocalizedString("Enabled", comment: "")
        let footer = LocalizedString("to Trade", comment: "")
        titleLabel.text = LocalizedString("\(header) \(transaction!.symbol) \(footer)", comment: "")
    }
    
    private func udpateCutoffAndCanceledOrder() {
        amountLabel.isHidden = true
        displayLabel.isHidden = true
        titleLabel.text = LocalizedString("Cancel Order(s)", comment: "")
    }
    
    private func updateReceived() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        titleLabel.text = transaction!.type.description + " " + transaction!.symbol
        amountLabel.text = "+\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.up
        displayLabel.text = transaction!.currency
    }
    
    private func updateSent() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        titleLabel.text = transaction!.type.description + " " + transaction!.symbol
        amountLabel.text = "-\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.down
        displayLabel.text = transaction!.currency
    }
    
    private func updateDefault() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        if let tx = self.transaction {
            if tx.type == .bought || tx.type == .received {
                amountLabel.textColor = UIColor.up
                amountLabel.text = "+\(tx.value) \(tx.symbol)"
            } else if tx.type == .sold || tx.type == .sent {
                amountLabel.textColor = UIColor.down
                amountLabel.text = "-\(tx.value) \(tx.symbol)"
            }
            displayLabel.text = tx.currency
            titleLabel.text = tx.type.description + " " + tx.symbol
        }
    }

    class func getCellIdentifier() -> String {
        return "UpdatedAssetTransactionTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
}
