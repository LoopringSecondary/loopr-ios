//
//  OrderBookTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/10/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OrderBookTableViewCell: UITableViewCell {

    var orderBook: OrderBook?

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var seperateLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // priceLabel.theme_textColor = GlobalPicker.textColor
        priceLabel.font = FontConfigManager.shared.getLabelFont()
        
        amountLabel.theme_textColor = GlobalPicker.textColor
        amountLabel.font = FontConfigManager.shared.getLabelFont()
        
        totalLabel.theme_textColor = GlobalPicker.textColor
        totalLabel.font = FontConfigManager.shared.getLabelFont()
        
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update() {
        guard let orderBook = orderBook else {
            return
        }
        if orderBook.side.lowercased() == "sell" {
            priceLabel.text = orderBook.price.withCommas(8)
            amountLabel.text = orderBook.amountSell.withCommas()
            totalLabel.text = orderBook.amountBuy.withCommas()
            priceLabel.textColor = UIStyleConfig.red
        } else if orderBook.side.lowercased() == "buy" {
            priceLabel.text = orderBook.price.withCommas(8)
            amountLabel.text = orderBook.amountBuy.withCommas()
            totalLabel.text = orderBook.amountSell.withCommas()
            priceLabel.textColor = UIStyleConfig.green
        }
    }
    
    class func getCellIdentifier() -> String {
        return "OrderBookTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }

}
