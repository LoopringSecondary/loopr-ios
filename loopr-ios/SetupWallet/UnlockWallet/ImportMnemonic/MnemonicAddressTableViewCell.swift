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
        indexLabel.font = FontConfigManager.shared.getRegularFont(size: 14)
        addressLabel.font = UIFont.init(name: FontConfigManager.shared.getLight(), size: 14)
    }
    
    class func getCellIdentifier() -> String {
        return "MnemonicAddressTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 44
    }
}
