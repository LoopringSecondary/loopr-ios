//
//  SettingCurrencyTableViewCell.swift
//  loopr-ios
//
//  Created by kenshin on 2018/4/22.
//  Copyright © 2018年 Loopring. All rights reserved.
//

import UIKit

class SettingCurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyDisplayLabel: UILabel!
    @IBOutlet weak var enabledIcon: UIImageView!

    @IBOutlet weak var seperateLineUp: UIView!
    @IBOutlet weak var seperateLineDown: UIView!
    
    var currency: Currency?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        selectionStyle = .none
        accessoryType = .none
        
        currencyDisplayLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        currencyDisplayLabel.theme_textColor = GlobalPicker.textLightColor

        theme_tintColor = GlobalPicker.textColor
        theme_backgroundColor = ColorPicker.cardBackgroundColor
        
        enabledIcon.image = UIImage(named: "enabled-dark")
        enabledIcon.contentMode = .center
        seperateLineUp.backgroundColor = UIColor.dark3
        seperateLineDown.backgroundColor = UIColor.dark3
    }

    class func getCellIdentifier() -> String {
        return "SettingCurrnecyTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 51
    }
    
    func update() {
        if let currency = self.currency {
            currencyDisplayLabel.text = currency.description
        }
    }

}
