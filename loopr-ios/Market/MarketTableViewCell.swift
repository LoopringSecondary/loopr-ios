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

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var marketPriceInBitcoinLabel: UILabel!
    @IBOutlet weak var marketPriceInFiatCurrencyLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        selectionStyle = .none

        theme_backgroundColor = GlobalPicker.backgroundColor
        baseView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        
        tokenImage.backgroundColor = UIColor.clear
        tokenImage.contentMode = .center

        nameLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        nameLabel.theme_textColor = GlobalPicker.textColor
        
        balanceLabel.setSubTitleDigitFont()
        balanceLabel.theme_textColor = GlobalPicker.textLightColor
        
        marketPriceInBitcoinLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        marketPriceInBitcoinLabel.theme_textColor = GlobalPicker.textColor
        
        marketPriceInFiatCurrencyLabel.font = FontConfigManager.shared.getRegularFont(size: 13)
        marketPriceInFiatCurrencyLabel.theme_textColor = GlobalPicker.textLightColor
        
        percentageChangeLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        percentageChangeLabel.textColor = UIColor.white
        percentageChangeLabel.textAlignment = .center
        percentageChangeLabel.cornerRadius = 6
        percentageChangeLabel.clipsToBounds = true

        accessoryType = .none
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
            if market.isFavorite() {
                tokenImage.image = UIImage(named: "Star")?.withRenderingMode(.alwaysOriginal)
            } else {
                tokenImage.image = UIImage(named: "StarOutline")?.withRenderingMode(.alwaysOriginal)
            }
            nameLabel.text = market.description
            nameLabel.setMarket()
            balanceLabel.text = "Vol \(market.volumeInPast24)"
            marketPriceInBitcoinLabel.text = market.balance.withCommas(6)
            marketPriceInFiatCurrencyLabel.text = market.display.description
            percentageChangeLabel.text = market.changeInPat24
            percentageChangeLabel.backgroundColor = UIStyleConfig.getChangeColor(change: market.changeInPat24)
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 60
    }
}
