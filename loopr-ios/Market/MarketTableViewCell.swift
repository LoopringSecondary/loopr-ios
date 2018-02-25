//
//  MarketTableViewCell.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketTableViewCell: UITableViewCell {

    var market: Market?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        nameLabel.theme_textColor = GlobalPicker.textColor
        balanceLabel.theme_textColor = ["#a0a0a0", "#fff"]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let market = market {
            nameLabel.text = "\(market.tradingPair.tradingA)" + " / " + "\(market.tradingPair.tradingB)"
            balanceLabel.text = "\(market.balance) \(market.tradingPair.tradingA)"
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
}
