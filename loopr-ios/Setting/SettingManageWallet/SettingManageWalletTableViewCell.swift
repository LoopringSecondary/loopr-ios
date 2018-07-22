//
//  SettingManageWalletTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/6/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SettingManageWalletTableViewCell: UITableViewCell {

    var wallet: AppWallet?
    
    @IBOutlet weak var baseView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var toatalBalanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        accessoryType = .none
        selectionStyle = .none
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        
        baseView.image = UIImage(named: "Header-background")
        baseView.contentMode = .scaleToFill
        
        nameLabel.font = FontConfigManager.shared.getRegularFont(size: 16)
        nameLabel.textColor = UIColor.init(white: 1, alpha: 1)
        
        toatalBalanceLabel.font = FontConfigManager.shared.getMediumFont(size: 24)
        toatalBalanceLabel.textColor = UIColor.init(white: 1, alpha: 0.9)
        
        addressLabel.font = FontConfigManager.shared.getMediumFont(size: 16)
        addressLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
    }

    func update() {
        if let wallet = wallet {
            nameLabel.text = wallet.name
            var balance = CurrentAppWalletDataManager.shared.getTotalAssetCurrencyFormmat()
            balance.insert(" ", at: balance.index(after: balance.startIndex))
            toatalBalanceLabel.text = balance
            addressLabel.text = wallet.address.getAddressFormat(length: 11)
        }
    }
    
    class func getCellIdentifier() -> String {
        return "SettingManageWalletTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 120+10
    }
}
