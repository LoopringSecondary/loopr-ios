//
//  MarketDetailDepthTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailDepthTableViewCell: UITableViewCell {

    var baseViewBuy: UIView = UIView()
    var baseViewSell: UIView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseViewBuy.frame = CGRect(x: 15, y: 0, width: (screenWidth - 15*2 - 5)*0.5, height: 32)
        baseViewBuy.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        addSubview(baseViewBuy)
        
        baseViewSell.frame = CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height)
        baseViewSell.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        addSubview(baseViewSell)
    }

    class func getCellIdentifier() -> String {
        return "MarketDetailDepthTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 32
    }
}
