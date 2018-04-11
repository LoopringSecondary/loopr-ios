//
//  AssetBalanceTableViewCell.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class AssetBalanceTableViewCell: UITableViewCell {

    var balanceLabel: TickerLabel = TickerLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        
        let originY: CGFloat = 20
        // let padding: CGFloat = 15
        
        balanceLabel.backgroundColor = UIColor.red
        
        balanceLabel.frame = CGRect(x: 0, y: originY, width: screenWidth, height: 40)
        balanceLabel.setFont(UIFont.init(name: FontConfigManager.shared.getRegular(), size: 27)!)
        balanceLabel.animationDuration = 0.25
        balanceLabel.textAlignment = NSTextAlignment.center
        balanceLabel.initializeLabel()
        balanceLabel.theme_backgroundColor = GlobalPicker.backgroundColor
        
        addSubview(balanceLabel)

        self.theme_backgroundColor = ["#fff", "#000"]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func update(asset: Asset) {
        balanceLabel.textColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
        balanceLabel.setText(asset.display, animated: false)
    }
    
    class func getCellIdentifier() -> String {
        return "AssetBalanceTableViewCell"
    }
    
    class func getHeight() -> CGFloat {
        return 244
    }

}
