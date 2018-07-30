//
//  MarketDetailDepthTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 7/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketDetailDepthTableViewCell: UITableViewCell {

    var buyDepth: Depth?
    var sellDepth: Depth?
    
    var baseViewBuy: UIView = UIView()
    var baseViewSell: UIView = UIView()
    
    var label1: UILabel = UILabel()
    var label2: UILabel = UILabel()
    var label3: UILabel = UILabel()
    var label4: UILabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clipsToBounds = true
        selectionStyle = .none
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        baseViewBuy.frame = CGRect(x: 15, y: 0, width: (screenWidth - 15*2 - 5)*0.5, height: 33+10)
        baseViewBuy.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        addSubview(baseViewBuy)
        
        label1 = UILabel(frame: CGRect(x: 10, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label1.theme_textColor = GlobalPicker.textLightColor
        label1.font = FontConfigManager.shared.getMediumFont(size: 12)
        label1.textAlignment = .left
        baseViewBuy.addSubview(label1)
        
        label2 = UILabel(frame: CGRect(x: 10 + label1.frame.maxX, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label2.theme_textColor = GlobalPicker.textLightColor
        label2.font = FontConfigManager.shared.getMediumFont(size: 12)
        label2.textAlignment = .right
        label2.textColor = UIColor.themeRed
        label2.lineBreakMode = .byCharWrapping
        baseViewBuy.addSubview(label2)
        
        baseViewSell.frame = CGRect(x: baseViewBuy.frame.maxX+5, y: baseViewBuy.frame.minY, width: baseViewBuy.width, height: baseViewBuy.height)
        baseViewSell.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        addSubview(baseViewSell)
        
        label3 = UILabel(frame: CGRect(x: 10, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label3.theme_textColor = GlobalPicker.textLightColor
        label3.font = FontConfigManager.shared.getMediumFont(size: 12)
        label3.textAlignment = .left
        baseViewSell.addSubview(label3)
        
        label4 = UILabel(frame: CGRect(x: 10 + label3.frame.maxX, y: 0, width: (baseViewBuy.width-30)*0.5, height: 33))
        label4.theme_textColor = GlobalPicker.textLightColor
        label4.font = FontConfigManager.shared.getMediumFont(size: 12)
        label4.textAlignment = .right
        label4.textColor = UIColor.themeGreen
        label4.lineBreakMode = .byClipping
        baseViewSell.addSubview(label4)
    }
    
    func update() {
        if let buyDepth = buyDepth {
            label1.text = buyDepth.amountA.toDecimalPlaces(2)
            label2.text = buyDepth.price.toDecimalPlaces(6)
        } else {
            label1.text = ""
            label2.text = ""
        }
        
        if let sellDepth = sellDepth {
            label3.text = sellDepth.amountA.toDecimalPlaces(2)
            label4.text = sellDepth.price.toDecimalPlaces(6)
        } else {
            label3.text = ""
            label4.text = ""
        }
    }

    class func getCellIdentifier() -> String {
        return "MarketDetailDepthTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 33
    }
}
