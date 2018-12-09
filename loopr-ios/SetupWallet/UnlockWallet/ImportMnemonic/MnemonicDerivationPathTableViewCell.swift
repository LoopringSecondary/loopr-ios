//
//  MnemonicDerivationPathTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicDerivationPathTableViewCell: UITableViewCell {

    @IBOutlet weak var pathDescriptionLabel: UILabel!
    @IBOutlet weak var pathValueLabel: UILabel!
    
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var enabledIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = ColorPicker.backgroundColor
        
        pathDescriptionLabel.font = FontConfigManager.shared.getMediumFont(size: 14)
        pathDescriptionLabel.theme_textColor = GlobalPicker.textColor
        
        pathValueLabel.font = FontConfigManager.shared.getRegularFont(size: 12)
        pathValueLabel.theme_textColor = GlobalPicker.textLightColor

        enabledIcon.image = UIImage(named: "enabled-dark")
        enabledIcon.contentMode = .center
        seperateLine.backgroundColor = UIColor.dark3
    }

    class func getCellIdentifier() -> String {
        return "MnemonicDerivationPathTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 65
    }
}
