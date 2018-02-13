//
//  OpenOrderTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/12/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class OpenOrderTableViewCell: UITableViewCell {

    var order: Order?
    
    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        guard let order = order else {
            return
        }
        tradingPairLabel.text = order.tradingPairDescription
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
}
