//
//  SettingStyleTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingStyleTableViewCell: UITableViewCell {

    enum ContentType {
        case regular
        case walletName
        case backupMnemonic
        case exportPrivateKey
        case exportKeystore
        case viewAddressOnEtherscan
        case clearRecords
    }
    
    var contentType: ContentType = .regular

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var seperateLineUp: UIView!
    @IBOutlet weak var seperateLineDown: UIView!
    @IBOutlet weak var trailingSeperateLineDown: NSLayoutConstraint!
    
    @IBOutlet weak var disclosureIndicator: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        seperateLineUp.backgroundColor = UIColor.dark3
        seperateLineDown.backgroundColor = UIColor.dark3
        
        theme_backgroundColor = ColorPicker.cardBackgroundColor

        leftLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        leftLabel.theme_textColor = GlobalPicker.textColor
        
        rightLabel.isHidden = true
        rightLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        rightLabel.theme_textColor = GlobalPicker.textLightColor

        disclosureIndicator.theme_image = GlobalPicker.indicator
        disclosureIndicator.contentMode = .center
    }

    class func getCellIdentifier() -> String {
        return "SettingStyleTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 51
    }

}
