//
//  OrderHistoryTableViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/2.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {

    var order: Order?
    
    @IBOutlet weak var filledPieChart: CircleChart!
    @IBOutlet weak var tradingPairLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update() {
        guard let order = self.order else { return }
        tradingPairLabel.text = order.tradingPairDescription
        volumeLabel.text = order.dealtAmountS.description
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getCellIdentifier() -> String {
        return "OrderHistoryTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
    
}
