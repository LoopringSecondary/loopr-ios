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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        indexLabel.textAlignment = .right
        indexLabel.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 14)
        addressLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getCellIdentifier() -> String {
        return "MnemonicAddressTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 44
    }
}
