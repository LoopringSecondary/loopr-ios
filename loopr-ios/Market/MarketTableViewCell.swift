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
        nameLabel.theme_textColor = GlobalPicker.textColor
        balanceLabel.theme_textColor = ["#a0a0a0", "#fff"]
        
        marketPriceInBitcoinLabel.theme_textColor = GlobalPicker.textColor
        marketPriceInFiatCurrencyLabel.theme_textColor = ["#a0a0a0", "#fff"]
        
        nameLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17)
        balanceLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 14)

        marketPriceInBitcoinLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 17)
        marketPriceInFiatCurrencyLabel.font = UIFont(name: FontConfigManager.shared.getLight(), size: 14)
        
        percentageChangeLabel.font = UIFont(name: FontConfigManager.shared.getRegular(), size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let market = market {
            tokenImage.image = market.icon
            nameLabel.text = "\(market.tradingPair.tradingA)" + " / " + "\(market.tradingPair.tradingB)"
            balanceLabel.text = "Vol \(market.volumeInPast24)"
            marketPriceInBitcoinLabel.text = market.balance.description
            marketPriceInFiatCurrencyLabel.text = market.display.description
            percentageChangeLabel.text = market.changeInPat24
            percentageChangeLabel.textColor = UIStyleConfig.getChangeColor(sign: market.changeInPat24.first?.description ?? "+")
        }
    }
    
    class func getCellIdentifier() -> String {
        return "MarketTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 84
    }
}
