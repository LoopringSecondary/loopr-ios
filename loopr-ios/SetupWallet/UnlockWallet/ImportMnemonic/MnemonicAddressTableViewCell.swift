//
//  MnemonicAddressTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var enabledIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = ColorPicker.backgroundColor
        
        indexLabel.textAlignment = .right
        indexLabel.font = FontConfigManager.shared.getMediumFont(size: 13)
        indexLabel.theme_textColor = GlobalPicker.textLightColor

        addressLabel.font = FontConfigManager.shared.getMediumFont(size: 13)
        addressLabel.theme_textColor = GlobalPicker.textLightColor
        
        enabledIcon.image = UIImage(named: "enabled-dark")
        enabledIcon.contentMode = .center
        seperateLine.backgroundColor = UIColor.dark3
    }
    
    class func getCellIdentifier() -> String {
        return "MnemonicAddressTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 65
    }
}
