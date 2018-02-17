//
//  AssetTableViewCell.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {

    var asset: Asset?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update() {
        if let asset = asset {
            iconImageView.image = asset.icon
            symbolLabel.text = asset.symbol
            balanceLabel.text = "\(asset.balance) \(asset.symbol)"
        }
    }
    
    class func getHeight() -> CGFloat {
        return 90
    }
}
