//
//  TradeTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/13/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class TradeTableViewCell: UITableViewCell {

    var order: Order?
    
    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update() {
        guard let order = order else {
            return
        }
        tradingPairLabel.text = order.tradingPairDescription
    }
    
    class func getCellIdentifier() -> String {
        return "TradeTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
}
