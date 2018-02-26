//
//  AssetBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        balanceLabel.theme_textColor = ["#000", "#fff"]
        balanceLabel.theme_backgroundColor = ["#fff", "#000"]
        self.theme_backgroundColor = ["#fff", "#000"]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getCellIdentifier() -> String {
        return "AssetBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 160
    }

}
