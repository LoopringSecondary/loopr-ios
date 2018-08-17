//
//  MarketChangeTokenTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketChangeTokenTableViewCell: UITableViewCell {

    var market: Market?

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marketPriceInBitcoinLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        
        nameLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        nameLabel.theme_textColor = GlobalPicker.textColor

        marketPriceInBitcoinLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        marketPriceInBitcoinLabel.theme_textColor = GlobalPicker.textColor

        percentageChangeLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            baseView.theme_backgroundColor = GlobalPicker.cardHighLightColor
        } else {
            baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        }
    }
    
    func update() {
        if let market = market {
            nameLabel.text = market.description
            nameLabel.setMarket()
            marketPriceInBitcoinLabel.text = market.balance.withCommas(6)
            percentageChangeLabel.text = market.changeInPat24
            percentageChangeLabel.textColor = UIStyleConfig.getChangeColor(change: market.changeInPat24)
        }
    }

    class func getCellIdentifier() -> String {
        return "MarketChangeTokenTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 40
    }

}
