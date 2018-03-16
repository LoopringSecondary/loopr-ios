//
//  AssetTransactionTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

//TODO: AssetTransactionTableViewCell is similar to OpenOrderTableViewCell and TradeTableViewCell. Keep AssetTransactionTableViewCell empty now.
class AssetTransactionTableViewCell: UITableViewCell {

    var transaction: Transaction?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = ["#fff", "#000"]
        titleLabel.theme_textColor = ["#000", "#fff"]
        descriptionLabel.theme_textColor = ["#a0a0a0", "#fff"]
        typeImageView.theme_image = ["Received", "Received-white"]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let transaction = transaction {
            typeImageView.image = transaction.icon
            titleLabel.text = transaction.type.description + " " + transaction.symbol
            switch transaction.type {
            case .received:
                descriptionLabel.text = "From " + transaction.from
            case .sent:
                descriptionLabel.text = "To " + transaction.to
            default:
                descriptionLabel.text = transaction.type.description
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
