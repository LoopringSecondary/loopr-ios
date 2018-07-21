//
//  SettingLanguageTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingLanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        leftLabel.theme_textColor = GlobalPicker.textColor
        
        theme_tintColor = GlobalPicker.textColor
        theme_backgroundColor = GlobalPicker.cardBackgroundColor
    }

    class func getCellIdentifier() -> String {
        return "SettingLanguageTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 51
    }
}
