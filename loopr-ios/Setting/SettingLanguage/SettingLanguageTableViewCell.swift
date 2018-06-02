//
//  SettingLanguageTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingLanguageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        textLabel?.theme_textColor = GlobalPicker.textColor
    }

    class func getCellIdentifier() -> String {
        return "SettingLanguageTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 44
    }
}
