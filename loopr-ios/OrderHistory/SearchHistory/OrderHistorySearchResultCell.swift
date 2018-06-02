//
//  OrderHistorySearchResultCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/5.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class OrderHistorySearchResultCell: UITableViewCell {

    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var token: Token?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update() {
        if token!.icon != nil {
            iconImageView.image = token!.icon
            iconImageView.isHidden = false
            iconView.isHidden = true
        } else {
            iconView.isHidden = false
            iconView.symbol = token!.symbol
            iconView.symbolLabel.text = token!.symbol
            iconImageView.isHidden = true
        }
        tokenLabel.text = token!.symbol + " (" + token!.source + ")"
    }

    class func getCellIdentifier() -> String {
        return "OrderHistorySearchResultCell"
    }
    
    class func getHeight() -> CGFloat {
        return 80
    }
    
}
