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
    }

    class func getCellIdentifier() -> String {
        return "SettingWalletDetailTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 45
    }
}
