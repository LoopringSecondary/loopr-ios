//
//  SwitchTradeTokenTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SwitchTradeTokenTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = FontConfigManager.shared.getLabelFont()

        theme_backgroundColor = GlobalPicker.backgroundColor
        titleLabel.theme_textColor = GlobalPicker.textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getCellIdentifier() -> String {
        return "SwitchTradeTokenTableViewCell"
    }

    class func getHeight() -> CGFloat {
        return 45
    }

}
