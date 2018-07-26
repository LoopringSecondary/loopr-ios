//
//  SettingWalletDetailTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingWalletDetailTableViewCell: UITableViewCell {

    enum ContentType {
        case walletName
        case backupMnemonic
        case exportPrivateKey
        case exportKeystore
        case clearRecords
    }
    
    var contentType: ContentType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textLabel?.font = FontConfigManager.shared.getMediumFont(size: 14)
        textLabel?.textColor = Themes.isDark() ? UIColor.white : UIColor.dark2
        backgroundColor = Themes.isDark() ? UIColor.dark2 : UIColor.white
    }

    class func getCellIdentifier() -> String {
        return "SettingWalletDetailTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 51
    }
}
