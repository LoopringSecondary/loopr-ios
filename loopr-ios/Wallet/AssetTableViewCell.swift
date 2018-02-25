//
//  AssetTableViewCell.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {

    var asset: Asset?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    @IBOutlet weak var forwardImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = ["#fff", "#000"]
        symbolLabel.theme_textColor = ["#000", "#fff"]
        balanceLabel.theme_textColor = ["#a0a0a0", "#fff"]
        amountLabel.theme_textColor = ["#a0a0a0", "#fff"]
        forwardImageView.theme_image = ["Forward", "Forward-white"]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let asset = asset {
            iconImageView.image = asset.icon
            symbolLabel.text = asset.symbol
            
            // TODO: Use values from Relay API.
            let balance = asset.balance * 120
            balanceLabel.text = "$\(balance)"
            amountLabel.text = "\(asset.balance) \(asset.symbol)"
        }
    }
    
    class func getCellIdentifier() -> String {
        return "AssetTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 84
    }
}
