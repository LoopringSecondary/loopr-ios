//
//  UpdatedAssetTransactionTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/9/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTransactionTableViewCell: UITableViewCell {

    var transaction: Transaction?
    var baseView: UIView = UIView()
    var typeImageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var statusImage: UIImageView = UIImageView()
    var dateLabel: UILabel = UILabel()
    var amountLabel: UILabel = UILabel()
    var displayLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        theme_backgroundColor = ColorPicker.backgroundColor
    
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        baseView.frame = CGRect.init(x: 15, y: 4, width: screenWidth - 15*2, height: AssetTransactionTableViewCell.getHeight() - 8)
        baseView.cornerRadius = 6
        addSubview(baseView)
        // applyShadow must be after addSubview
        baseView.applyShadow(withColor: UIColor.black)
        
        typeImageView.frame = CGRect.init(x: 20, y: 20, width: 28, height: 28)
        typeImageView.contentMode = .scaleAspectFit
        baseView.addSubview(typeImageView)
        
        titleLabel.frame = CGRect.init(x: 64, y: 16, width: 200, height: 36)
        titleLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        titleLabel.theme_textColor = GlobalPicker.textColor
        titleLabel.text = "ETHETHETHETHETHETHETH"
        titleLabel.sizeToFit()
        titleLabel.text = ""
        baseView.addSubview(titleLabel)
        
        dateLabel.frame = CGRect.init(x: titleLabel.frame.minX, y: 41, width: 200, height: 27)
        dateLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        dateLabel.theme_textColor = GlobalPicker.textLightColor
        dateLabel.text = "ETHETHETHETHETHETHETH"
        dateLabel.sizeToFit()
        dateLabel.text = ""
        baseView.addSubview(dateLabel)
        
        amountLabel.frame = CGRect.init(x: baseView.frame.width - 20 - 200, y: titleLabel.frame.minY, width: 200, height: titleLabel.frame.size.height)
        amountLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        amountLabel.textAlignment = .right
        baseView.addSubview(amountLabel)
        
        displayLabel.frame = CGRect.init(x: amountLabel.frame.minX, y: dateLabel.frame.minY, width: 200, height: dateLabel.frame.size.height)
        displayLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        displayLabel.theme_textColor = GlobalPicker.textLightColor
        displayLabel.textAlignment = .right
        baseView.addSubview(displayLabel)
        
        baseView.addSubview(statusImage)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = ColorPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = ColorPicker.cardBackgroundColor
        }
    }
    
    func update() {
        if let tx = transaction {
            switch tx.type {
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
            typeImageView.image = tx.icon
            dateLabel.text = tx.createTime
            updateStatusImage(transaction: tx)
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
            titleLabel.text = LocalizedString("Convert to ETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel.text = LocalizedString("Convert to WETH", comment: "")
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
        titleLabel.text = LocalizedString("Cancel Order", comment: "")
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
    
    func updateStatusImage(transaction: Transaction) {
        let x = titleLabel.intrinsicContentSize.width + titleLabel.frame.minX + 15
        statusImage.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 15, height: 15))
        statusImage.center = CGPoint(x: x, y: titleLabel.frame.midY)
        
        switch transaction.status {
        case .success:
            self.statusImage.image = UIImage(named: "Checked")
        case .pending:
            self.statusImage.image = UIImage(named: "Clock")
        case .failed:
            self.statusImage.image = UIImage(named: "Warn")
        default:
            self.statusImage.image = UIImage(named: "Checked")
        }
    }

    class func getCellIdentifier() -> String {
        return "AssetTransactionTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 76
    }
}
