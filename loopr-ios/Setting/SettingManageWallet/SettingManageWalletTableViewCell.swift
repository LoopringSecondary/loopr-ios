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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var seperateLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.font = FontConfigManager.shared.getLabelFont(size: 21)
        addressLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
        addressLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        
        tintColor = UIColor.black
    }

    func update() {
        if let wallet = wallet {
            nameLabel.text = wallet.name
            addressLabel.text = wallet.address
        }
    }
    
    class func getCellIdentifier() -> String {
        return "SelectWalletTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 82
    }
}
