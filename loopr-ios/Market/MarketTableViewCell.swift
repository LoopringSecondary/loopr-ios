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

    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var tokenImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var marketPriceInBitcoinLabel: UILabel!
    @IBOutlet weak var marketPriceInFiatCurrencyLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        theme_backgroundColor = GlobalPicker.backgroundColor

        nameLabel.setTitleFont()
        balanceLabel.setSubTitleFont()
        balanceLabel.isHidden = true
        marketPriceInBitcoinLabel.setTitleFont()
        marketPriceInFiatCurrencyLabel.setSubTitleFont()
        percentageChangeLabel.setTitleFont()
        accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let market = market {
            if market.icon != nil {
                tokenImage.image = market.icon
                tokenImage.isHidden = false
                iconView.isHidden = true
            } else {
                iconView.isHidden = false
                iconView.symbol = market.tradingPair.tradingA
                iconView.symbolLabel.text = market.tradingPair.tradingA
                tokenImage.isHidden = true
            }
            nameLabel.text = market.description
            nameLabel.setMarket()
            balanceLabel.text = "Vol \(market.volumeInPast24)"
            marketPriceInBitcoinLabel.text = market.balance.description
            marketPriceInFiatCurrencyLabel.text = market.display.description
            percentageChangeLabel.text = market.changeInPat24
            percentageChangeLabel.textColor = UIStyleConfig.getChangeColor(change: market.changeInPat24)
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketTableViewCell"
    }
    
    //TODO: The height of MarketTableViewCell is different from the height of AssetTableViewCell.
    class func getHeight() -> CGFloat {
        return 72*UIStyleConfig.scale
    }
}
