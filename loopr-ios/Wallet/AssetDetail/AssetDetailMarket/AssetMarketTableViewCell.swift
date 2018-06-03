//
//  AssetMarketTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetMarketTableViewCell: UITableViewCell {

    var market: Market?
    
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentageChangeLabel: UILabel!
    @IBOutlet weak var seperateLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        exchangeLabel.font = FontConfigManager.shared.getLabelFont()
        priceLabel.font = FontConfigManager.shared.getLabelFont()
        percentageChangeLabel.font = FontConfigManager.shared.getLabelFont()
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
    }
    
    func update() {
        guard let market = market else {
            return
        }
        exchangeLabel.text = market.getExchangeDescription()
        if market.last != nil {
            priceLabel.text = market.last!.description
        } else {
            priceLabel.text = ""
        }
        percentageChangeLabel.text = market.changeInPat24
        percentageChangeLabel.textColor = UIStyleConfig.getChangeColor(change: market.changeInPat24)
    }

    class func getCellIdentifier() -> String {
        return "AssetMarketTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }
}
