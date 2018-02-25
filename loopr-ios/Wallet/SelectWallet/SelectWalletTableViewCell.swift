//
//  SelectWalletTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class SelectWalletTableViewCell: UITableViewCell {
    
    var wallet: Wallet?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        theme_backgroundColor = GlobalPicker.backgroundColor
        nameLabel.theme_textColor = GlobalPicker.textColor
        addressLabel.theme_textColor = GlobalPicker.textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        return 90
    }

}
