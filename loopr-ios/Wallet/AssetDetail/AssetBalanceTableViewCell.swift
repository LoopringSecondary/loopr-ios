//
//  AssetBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: TickerLabel!
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet weak var seperateLine: UIView!
    
    var asset: Asset?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupLabel()
        seperateLine.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        seperateLine.isHidden = true
        self.theme_backgroundColor = ["#fff", "#000"]
    }
    
    func setupLabel() {
        balanceLabel.animationDuration = 0.25
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor
        balanceLabel.textColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        balanceLabel.setFont(FontConfigManager.shared.getRegularFont(size: 27))
    }

    func update() {
        if let asset = self.asset {
            balanceLabel.setText(asset.balance.description, animated: false)
            displayLabel.text = asset.display
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    class func getCellIdentifier() -> String {
        return "AssetBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 150
    }
}
