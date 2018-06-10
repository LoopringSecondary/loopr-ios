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
        
        backgroundColor = UIStyleConfig.tableViewBackgroundColor
        baseView.backgroundColor = UIColor.white
        baseView.frame = CGRect.init(x: 10, y: 10, width: screenWidth - 10*2, height: UpdatedAssetTransactionTableViewCell.getHeight() - 10)
        addSubview(baseView)
        
        typeImageView.frame = CGRect.init(x: 15, y: 15, width: 30, height: 30)
        typeImageView.contentMode = .scaleAspectFit
        baseView.addSubview(typeImageView)
        
        titleLabel.frame = CGRect.init(x: 60, y: 13-3, width: 200, height: 31/2)
        titleLabel.font = FontConfigManager.shared.getRegularFont(size: 15)
        titleLabel.text = "ETHETHETHETHETHETHETH"  // Prototype the label size. Will be updated very soon.
        titleLabel.sizeToFit()
        titleLabel.text = ""
        baseView.addSubview(titleLabel)
        
        dateLabel.frame = CGRect.init(x: titleLabel.frame.minX, y: 35-3, width: 200, height: 27)
        dateLabel.setSubTitleFont()
        dateLabel.text = "ETHETHETHETHETHETHETH"
        dateLabel.sizeToFit()
        dateLabel.text = ""
        baseView.addSubview(dateLabel)
        
        amountLabel.frame = CGRect.init(x: baseView.frame.width - 15 - 200, y: titleLabel.frame.minY, width: 200, height: titleLabel.frame.size.height)
        amountLabel.font = FontConfigManager.shared.getRegularFont(size: 15)
        amountLabel.textAlignment = .right
        baseView.addSubview(amountLabel)
        
        displayLabel.frame = CGRect.init(x: amountLabel.frame.minX, y: dateLabel.frame.minY, width: 200, height: dateLabel.frame.size.height)
        displayLabel.setSubTitleFont()
        displayLabel.textAlignment = .right
        baseView.addSubview(displayLabel)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.backgroundColor = UIStyleConfig.tableCellSelectedBackgroundColor
        } else {
            baseView.backgroundColor = UIColor.white
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
            case .received:
                updateReceived()
            case .sent:
                updateSent()
            default:
                updateDefault()
            }
        }
    }
    
    private func updateConvertIncome() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        if transaction!.symbol.lowercased() == "weth" {
            titleLabel.text = NSLocalizedString("Convert to WETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel.text = NSLocalizedString("Convert to ETH", comment: "")
        }
        amountLabel.text = "\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.black
        displayLabel.text = transaction!.currency
    }
    
    private func updateConvertOutcome() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        if transaction!.symbol.lowercased() == "weth" {
            titleLabel.text = NSLocalizedString("Convert to WETH", comment: "")
        } else if transaction!.symbol.lowercased() == "eth" {
            titleLabel.text = NSLocalizedString("Convert to ETH", comment: "")
        }
        amountLabel.text = "\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.black
        displayLabel.text = transaction!.currency
    }
    
    private func updateApprove() {
        amountLabel.isHidden = true
        displayLabel.isHidden = true
        let header = NSLocalizedString("Enabled", comment: "")
        let footer = NSLocalizedString("to Trade", comment: "")
        titleLabel.text = NSLocalizedString("\(header) \(transaction!.symbol) \(footer)", comment: "")
    }
    
    private func udpateCutoffAndCanceledOrder() {
        amountLabel.isHidden = true
        displayLabel.isHidden = true
        titleLabel.text = NSLocalizedString("Cancel Order(s)", comment: "")
    }
    
    private func updateReceived() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        titleLabel.text = transaction!.type.description + " " + transaction!.symbol
        amountLabel.text = "+\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIStyleConfig.getChangeColor(change: amountLabel.text!)
        displayLabel.text = transaction!.currency
    }
    
    private func updateSent() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        titleLabel.text = transaction!.type.description + " " + transaction!.symbol
        amountLabel.text = "-\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIStyleConfig.getChangeColor(change: amountLabel.text!)
        displayLabel.text = transaction!.currency
    }
    
    private func updateDefault() {
        amountLabel.isHidden = false
        displayLabel.isHidden = false
        titleLabel.text = transaction!.type.description + " " + transaction!.symbol
        amountLabel.text = "\(transaction!.value) \(transaction?.symbol ?? " ")"
        amountLabel.textColor = UIColor.black
        displayLabel.text = transaction!.currency
    }

    class func getCellIdentifier() -> String {
        return "UpdatedAssetTransactionTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 70
    }
    
}
